# Xendit Setup Guide (Sandbox / Test Mode)

How to register a Xendit account, get sandbox credentials, and wire them into this
app for local development. Follow this end to end before trying to take a test
payment — nothing works until steps 2, 3 and 4 are done.

BGRC supports two gateways behind one interface (`app/services/payment_gateways/`).
`PAYMENT_GATEWAY` decides where new payments go. It defaults to `midtrans`, so
switching to Xendit is a deliberate opt-in, and switching back is one env var and
a restart — no deploy, and no effect on how existing purchases are read.

---

## 1. Create the account

Register at **https://dashboard.xendit.co/register**.

Test Mode works immediately — you do **not** need business verification for it.
Verification is only required to unlock Live Mode and move real money.

The dashboard shows the active mode in the **bottom-left corner**. Confirm it says
**Test Mode** before you generate any keys. Every key, callback token and webhook
URL below is per-mode: the test set and the live set are entirely separate.

## 2. Create a secret API key

**Settings → Developers → API Keys → Generate secret key**

Xendit does not ship a secret key by default (only public keys), so you have to
create one. The dialog is a permission grid: each row (Conversions, Money-in
products, Money-out products, Balance, ...) is a single **None / Read / Write**
choice, not independent checkboxes — you cannot select both Read and Write on
the same row, and that is expected. Per Xendit's own docs, **Write already
includes Read** for that row, so:

| Row | Level | Why |
|---|---|---|
| **Money-in products** | **Write** | covers both creating invoices (`PaymentGateways::Xendit.checkout`) and the read-only status lookups (the return-URL check and `payments:reconcile`) |
| Everything else | None | this app only creates and reads invoices — no payouts, disbursements, or conversions |

Give the key a name (anything descriptive works, e.g. `bgrc_web`), leave every
other row at **None**, and click **Generate key**.

Test keys are prefixed `xnd_development_`. **The secret is shown once** — copy it
straight into `.env`; if you lose it, delete the key and make a new one.

> There is no separate sandbox hostname. Both modes use `https://api.xendit.co`,
> and the key prefix alone decides whether you are moving real money. This is the
> main difference from Midtrans, which used distinct `sandbox.` URLs.

## 3. Get the callback verification token

**Settings → Developers → Webhooks → Webhook verification token**

This is a *different* secret from the API key. Xendit sends it in the
`x-callback-token` header on every callback, and `Webhooks::BaseController`
rejects anything whose token does not match with a 401. It is the same value for
all webhook types on the account.

## 4. Point the webhooks at your machine

Xendit has to reach your dev server, so run a tunnel:

```bash
ngrok http 3000
# or
cloudflared tunnel --url http://localhost:3000
```

Then in **Settings → Developers → Webhooks**, set both:

| Event | URL |
|---|---|
| Invoices paid | `https://<your-tunnel-host>/webhooks/xendit` |
| Invoices expired | `https://<your-tunnel-host>/webhooks/xendit` |

Rails' host authorization already allows `*.ngrok-free.app`, `*.ngrok.io` and
`*.trycloudflare.com` (see `config/environments/development.rb`). For any other
tunnel, set `DEV_TUNNEL_HOST` in `.env` instead of editing the config.

## 5. Environment variables

Add to `.env` (which is gitignored — see the note at the end):

```sh
PAYMENT_GATEWAY=xendit
XENDIT_SECRET_KEY=xnd_development_...
XENDIT_CALLBACK_TOKEN=...
# only if your tunnel is not ngrok or cloudflared
# DEV_TUNNEL_HOST=my-tunnel.example.com
```

Restart the server afterwards — `.env` is read at boot.

Full list of variables this app understands:

| Variable | Default | Purpose |
|---|---|---|
| `PAYMENT_GATEWAY` | `midtrans` | `xendit` or `midtrans` |
| `XENDIT_SECRET_KEY` | — | secret API key |
| `XENDIT_CALLBACK_TOKEN` | — | webhook verification token |
| `XENDIT_API_URL` | `https://api.xendit.co` | rarely changed |
| `DEV_TUNNEL_HOST` | — | extra allowed host in development |
| `MIDTRANS_SERVER_KEY` / `MIDTRANS_CLIENT_KEY` / `MIDTRANS_MERCHANT_ID` | — | legacy gateway |
| `MIDTRANS_API_URL` / `MIDTRANS_JS_FILE` / `MIDTRANS_STATUS_API_URL` | sandbox URLs | legacy gateway |

## 6. Enable payment channels

**Settings → Payment channels** (in Test Mode).

Turn on what you want customers to see: virtual accounts (BCA, BNI, BRI, Mandiri,
Permata), QRIS, e-wallets (OVO, DANA, ShopeePay, LinkAja), retail outlets
(Alfamart, Indomaret) and cards. A channel that is off simply will not appear on
the hosted checkout page — this is the first thing to check if a payment method
is missing.

## 7. Take a test payment

Test Mode uses virtual funds; nothing is ever charged.

1. Start the app and a tunnel, and make a booking as a normal user.
2. Click **Pay** and accept the disclaimer. You should be redirected to
   `https://checkout-staging.xendit.co/web/...`.
3. Pick a channel and complete it:
   - **Virtual account / retail / QRIS** — open the invoice under
     **Transactions** in the dashboard and use its simulate-payment action. The
     API equivalent for v3 payment requests is
     `POST /v3/payment_requests/{id}/simulate`, which returns `PENDING` and
     delivers the outcome by webhook.
   - **Cards** — use the numbers on Xendit's *test cards* documentation page.
     Do not reuse the Midtrans test card from `docs/testing/CREDENTIALS.md`; the
     two gateways have different lists, and Xendit's are versioned per channel.
4. You should be redirected back to the booking page, which will read **Paid**.

### Checking the webhook

**Settings → Developers → Webhooks** lists every delivery attempt with its
response code:

| Code | Meaning |
|---|---|
| `200` | accepted and applied |
| `401` | token mismatch — `XENDIT_CALLBACK_TOKEN` is wrong or missing |
| `500` | reached the app but something raised; check `log/development.log` |

Xendit **retries** anything that is not 2xx, which is why
`Purchase#apply_gateway_result!` takes a row lock and no-ops on an
already-settled purchase. Re-sending a delivery from the dashboard is a safe way
to prove that: it must not send a second confirmation email.

## 8. Recovering payments the webhook missed

Two safety nets, because a customer can always close the tab mid-payment:

- **On return.** If they come back with `?payment=success` while the purchase is
  still pending, the app does one status lookup and settles it immediately
  (`PaymentReconciliation`).
- **Sweep.** `bin/rails payments:reconcile` checks every pending gateway purchase
  from the last 7 days and settles whatever the gateway says is paid. Run it from
  cron in production, e.g. every 10 minutes:

  ```
  */10 * * * * cd /path/to/app && bin/rails payments:reconcile >> log/reconcile.log 2>&1
  ```

  `bin/rails payments:pending` lists what is outstanding without calling the
  gateway. `RECONCILE_LOOKBACK_DAYS` changes the window.

## 9. Key hygiene

- Never commit keys. `.env` is ignored by `.gitignore` (`/.env*`), and so is
  `.env.example` — the only exception in that rule is `!/.env*.erb`, so a
  committed template has to be named `.env.example.erb`. This guide is the
  reference for which variables exist.
- Rotate immediately if a key leaks: delete it in the dashboard and generate a
  new one. Deleting a key takes effect at once.
- The test callback token and the live callback token are different values. Do
  not carry one across.

> **Two things to settle before go-live.** The existing `.env` holds Midtrans
> *sandbox* credentials, and `config/configatron/production.rb` used to point
> production at the Midtrans sandbox URL. Establish whether any real payment has
> ever been processed through this app before planning a data migration.

## 10. Going live

1. Complete business verification to unlock Live Mode.
2. Switch the dashboard to Live Mode and generate an `xnd_production_` secret key
   with the same two permissions.
3. Copy the **live** webhook verification token — it differs from the test one.
4. Set the live webhook URLs to
   `https://balibeachcountryclub.com/webhooks/xendit`.
5. Set `PAYMENT_GATEWAY`, `XENDIT_SECRET_KEY` and `XENDIT_CALLBACK_TOKEN` in the
   production environment and restart.
6. Verify with one small real transaction, confirm the webhook returned 200, then
   refund it from the dashboard.

## Rolling back to Midtrans

Set `PAYMENT_GATEWAY=midtrans` and restart. New payments go through Snap again;
existing Xendit purchases keep resolving to the Xendit adapter, because the
gateway is recorded per row.

One extra step if you do this: set the **Payment Notification URL** in the
Midtrans dashboard to `https://<host>/webhooks/midtrans`. Midtrans payments are
recorded from that verified notification (signature-checked), not from the
browser. Without it, payments will complete at the gateway and never be recorded.

---

## Troubleshooting

| Symptom | Cause |
|---|---|
| "Online payment is unavailable right now" | `XENDIT_SECRET_KEY` unset — restart after editing `.env` |
| "We could not reach the payment provider" | network/timeout to `api.xendit.co`; check the tunnel and `log/development.log` |
| Webhook shows 401 in the dashboard | `XENDIT_CALLBACK_TOKEN` does not match the dashboard's verification token |
| Webhook shows 500 | app error — the log line is prefixed `[xendit]` |
| Paid at the gateway but still pending in-app | webhook never arrived; run `bin/rails payments:reconcile` and fix the webhook URL |
| `Blocked hosts` error on the tunnel URL | add the host via `DEV_TUNNEL_HOST` |
| A payment method is missing at checkout | that channel is off in **Settings → Payment channels** |
| Invoice expires almost immediately | expected — the invoice inherits the booking's *remaining* payment window, not a fresh 10 minutes |
