#!/usr/bin/env bash
# Run on the server as deployer, from /home/deployer/preproduction/bgrc.
# Usage:  deploy/deploy.sh [branch]      (default: preproduction)
set -euo pipefail

BRANCH="${1:-preproduction}"
cd /home/deployer/preproduction/bgrc

# `source` the env file so rake/bundler see the same variables as Unicorn.
set -a
source .env.production
set +a

git fetch origin
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

bundle config set --local deployment true
bundle config set --local without 'development test'
bundle install
bin/rails db:migrate
bin/rails assets:precompile

sudo systemctl restart bgrc-unicorn
sleep 3
sudo systemctl --no-pager status bgrc-unicorn | head -5
