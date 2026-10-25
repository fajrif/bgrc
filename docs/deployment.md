# Pre-production deployment: Unicorn + Nginx + production database

Moves the pre-production server (128.199.83.171) from Puma on port 3000 (development database) to Unicorn behind Nginx, with a `bgrc_production` database. Deploys the `preproduction` branch, which keeps the jQuery/RJS front end and has no Vue.

Config files live in `deploy/` and `config/`:

| File | Goes to |
|---|---|
| `config/nginx.conf` | `/etc/nginx/nginx.conf` (replaces it; no sites-available) |
| `config/unicorn.rb` | used in place |
| `deploy/bgrc-unicorn.service` | `/etc/systemd/system/` |
| `deploy/env.production.example` | `/home/deployer/bgrc/.env.production` |
| `deploy/make-ip-cert.sh` | run once |
| `deploy/bgrc.cron` | `/etc/cron.d/bgrc` |
| `deploy/bgrc.logrotate` | `/etc/logrotate.d/bgrc` |

Run everything as `deployer` unless a step says `sudo` or `postgres`. Nothing here modifies the running Puma site or the development database until step 9.

---

## 1. Inspect (read-only)

Find where Puma runs from, and what the dev database looks like.

```bash
ls -l /proc/$(pgrep -f puma | head -1)/cwd        # this is <DEV_DIR>
psql -h localhost -U deployer bgrc_development
```

```sql
\dn                          -- which schema holds the tables: public or myapp?
\dt *.purchases              -- confirms it
SELECT order_id, count(*) FROM purchases GROUP BY 1 HAVING count(*) > 1;   -- must return no rows
SELECT 'users' t, count(*) FROM users UNION ALL
SELECT 'bookings', count(*) FROM bookings UNION ALL
SELECT 'purchases', count(*) FROM purchases UNION ALL
SELECT 'golf_reservations', count(*) FROM golf_reservations UNION ALL
SELECT 'food_orders', count(*) FROM food_orders UNION ALL
SELECT 'active_storage_blobs', count(*) FROM active_storage_blobs;         -- save this output
```

If the duplicate `order_id` query returns rows, fix them before step 5, because the new unique index fails otherwise.

## 2. Put the code on the server

Production runs from a fresh clone. The Puma checkout stays untouched.

```bash
cd /home/deployer
git clone -b preproduction <origin-url> bgrc
cd bgrc
rvm use ruby-3.3.0@bgrc --create        # .ruby-gemset is "bgrc"
ls /home/deployer/.rvm/wrappers/        # expect ruby-3.3.0@bgrc, as used in deploy/bgrc-unicorn.service
mkdir -p tmp/pids tmp/sockets log
```

## 3. Environment file

```bash
cp deploy/env.production.example .env.production
chmod 600 .env.production
bin/rails secret                         # paste the output as SECRET_KEY_BASE
nano .env.production
```

For pre-production: `SITE_URL=https://128.199.83.171`, `FORCE_SSL=true`, **`PAYMENT_GATEWAY=midtrans`** and the Midtrans sandbox keys. Copy the key values from `<DEV_DIR>/.env` (the Midtrans and reCAPTCHA entries). Xendit keys can be filled now and stay unused while `PAYMENT_GATEWAY=midtrans`.

```bash
bundle install --deployment --without development test
```

## 4. Restore the database (rehearsal)

```bash
# dump from the development database (Puma can keep running)
PGPASSWORD='deployer1234!' pg_dump -Fc -h localhost -U deployer bgrc_development -f ~/bgrc_dev.dump

# create the production database (as the postgres user)
sudo -u postgres createdb -O deployer bgrc_production

# restore
PGPASSWORD='deployer1234!' pg_restore --no-owner --role=deployer -h localhost -U deployer \
  -d bgrc_production ~/bgrc_dev.dump
```

Then mark it as a production database. Rails refuses some tasks when this row says `development`.

```bash
psql -h localhost -U deployer bgrc_production \
  -c "UPDATE ar_internal_metadata SET value='production' WHERE key='environment';"
```

## 5. Migrate

```bash
set -a; source .env.production; set +a
bin/rails db:migrate:status | tail -5     # 20260910000001 should be "down"
bin/rails db:migrate                      # adds the gateway columns and the unique order_id index
```

**Do not run `db:seed`.** The restored data already has the seed content, and seeding would duplicate it.

## 6. Uploaded files and assets

Active Storage uses the `storage/` directory (Disk service). Copy it from the dev checkout.

```bash
rsync -a <DEV_DIR>/storage/ /home/deployer/bgrc/storage/
[ -d <DEV_DIR>/public/uploads ] && rsync -a <DEV_DIR>/public/uploads/ public/uploads/

bin/rails assets:precompile
bin/rails runner 'puts ActiveStorage::Blob.count; puts ActiveStorage::Blob.all.count { |b| !b.service.exist?(b.key) }'
# second number = blobs whose file is missing; it should be 0
```

Compare the row counts from step 1 with `bin/rails runner 'puts User.count, Booking.count, Purchase.count'`.

## 7. Nginx, certificate, service

```bash
deploy/make-ip-cert.sh                                   # self-signed cert for 128.199.83.171

sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.lightstein.bak
ls /etc/nginx/conf.d/                                    # should be empty of old Lightstein files
sudo cp config/nginx.conf /etc/nginx/nginx.conf
sudo nginx -t

sudo cp deploy/bgrc-unicorn.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now bgrc-unicorn
sudo systemctl status bgrc-unicorn
sudo systemctl reload nginx
```

Open the firewall for 80 and 443 if it is closed (`sudo ufw allow 80,443/tcp`, or the equivalent on this host). On CentOS-like hosts nginx needs SELinux off or permissive (see the note at the top of `nginx.conf`), because it reads the Unicorn socket under `/home`.

Check:

```bash
curl -kI https://128.199.83.171/            # 200
curl -I  http://128.199.83.171/             # 301 to https
tail -f log/unicorn.log
```

In the browser, open `https://128.199.83.171` and accept the certificate warning. Puma on `:3000` still works at this point.

## 8. Payment gateway check

```bash
bin/rails payments:gateway
```

It shows the active gateway, whether its keys are set, and the webhook URLs. Make a Midtrans sandbox booking, pay it, and confirm the browser returns to `https://128.199.83.171/...` (not the live domain) and the booking shows as paid.

Midtrans and Xendit cannot call webhooks over the self-signed certificate. Payments still settle when the customer returns to the order page, and `payments:reconcile` (step 10) settles the rest.

**Switching the gateway:**

```bash
nano /home/deployer/bgrc/.env.production        # PAYMENT_GATEWAY=xendit  (or midtrans)
sudo systemctl restart bgrc-unicorn             # restart, not reload: reload keeps the old environment
cd /home/deployer/bgrc && set -a && . ./.env.production && set +a && bin/rails payments:gateway
```

Purchases remember their own gateway, so switching never changes payments already under way.

## 9. Final cutover

When the rehearsal is clean, repeat with fresh data, so nothing entered since step 4 is lost.

```bash
screen -ls                                  # find the Puma session
screen -S <session> -X quit                 # stop Puma (site is down from here)

sudo systemctl stop bgrc-unicorn
PGPASSWORD='deployer1234!' pg_dump -Fc -h localhost -U deployer bgrc_development -f ~/bgrc_dev_final.dump
sudo -u postgres dropdb bgrc_production
sudo -u postgres createdb -O deployer bgrc_production
PGPASSWORD='deployer1234!' pg_restore --no-owner --role=deployer -h localhost -U deployer \
  -d bgrc_production ~/bgrc_dev_final.dump
psql -h localhost -U deployer bgrc_production \
  -c "UPDATE ar_internal_metadata SET value='production' WHERE key='environment';"

cd /home/deployer/bgrc && set -a && . ./.env.production && set +a
bin/rails db:migrate
rsync -a --delete <DEV_DIR>/storage/ storage/
sudo systemctl start bgrc-unicorn
```

Delete test data in the admin panel or `psql` after this. The dev database and `<DEV_DIR>` are never modified, so they are the rollback.

## 10. Cron and log rotation

```bash
sudo cp deploy/bgrc.cron /etc/cron.d/bgrc
sudo cp deploy/bgrc.logrotate /etc/logrotate.d/bgrc
sudo systemctl status cron || sudo systemctl status crond
```

`payments:reconcile` runs every 10 minutes and settles payments whose webhook never arrived.

Later deploys: `deploy/deploy.sh` (pull, bundle, migrate, precompile, restart).

## Rollback

```bash
sudo systemctl stop bgrc-unicorn
sudo cp /etc/nginx/nginx.conf.lightstein.bak /etc/nginx/nginx.conf && sudo systemctl reload nginx
cd <DEV_DIR> && screen -dmS puma bin/rails s -b 0.0.0.0 -p 3000      # as it was started before
```

## Go-live (domain pointed at 128.199.83.171)

1. Install the real certificate: `/home/deployer/.ssl/balibeachcountryclub.com.chained.crt` and `.key` (or use certbot).
2. In `/etc/nginx/nginx.conf`, uncomment the Phase 2 server blocks and remove the two IP blocks (or at least their `default_server`). Run `sudo nginx -t && sudo systemctl reload nginx`.
3. In `.env.production`: `SITE_URL=https://www.balibeachcountryclub.com`, `FORCE_SSL=true`. For live payments, switch to the live gateway keys. Midtrans needs the three `app.midtrans.com` / `api.midtrans.com` URLs (see the comments in `env.production.example`). Xendit needs an `xnd_production_` key.
4. Register the webhook URLs printed by `bin/rails payments:gateway` in the gateway dashboard. They have to be HTTPS on the real domain.
5. `sudo systemctl restart bgrc-unicorn`, then make one small real payment.
