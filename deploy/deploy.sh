#!/usr/bin/env bash
# Run on the server as deployer, from /home/deployer/bgrc.
# Usage:  deploy/deploy.sh [branch]      (default: preproduction)
set -euo pipefail

BRANCH="${1:-preproduction}"
cd /home/deployer/bgrc

# `source` the env file so rake/bundler see the same variables as Unicorn.
set -a
source .env.production
set +a

git fetch origin
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

bundle install --deployment --without development test
bin/rails db:migrate
bin/rails assets:precompile

sudo systemctl restart bgrc-unicorn
sleep 3
sudo systemctl --no-pager status bgrc-unicorn | head -5
