#!/usr/bin/env bash
# Self-signed certificate for the server's IP, for the pre-production phase only.
# Browsers will warn; payment gateways cannot call webhooks over it.
# Usage:  deploy/make-ip-cert.sh [ip]
set -euo pipefail

IP="${1:-128.199.83.171}"
DIR="/home/deployer/.ssl"

mkdir -p "$DIR"
chmod 700 "$DIR"

openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout "$DIR/bgrc-ip.key" -out "$DIR/bgrc-ip.crt" \
  -subj "/CN=$IP" \
  -addext "subjectAltName=IP:$IP"

chmod 600 "$DIR/bgrc-ip.key"
echo "Wrote $DIR/bgrc-ip.crt and $DIR/bgrc-ip.key (valid 365 days)"
