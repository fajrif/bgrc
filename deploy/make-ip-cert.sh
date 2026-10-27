#!/usr/bin/env bash
# Self-signed certificate for the server's IP, for the pre-production phase only.
# Browsers will warn; payment gateways cannot call webhooks over it.
# Usage:  deploy/make-ip-cert.sh [ip]
set -euo pipefail

IP="${1:-128.199.83.171}"
DIR="/home/deployer/.ssl"

mkdir -p "$DIR"
chmod 700 "$DIR"

# A config file instead of `-addext`, which needs OpenSSL 1.1.1+ (CentOS 7 has 1.0.2).
CONF="$(mktemp)"
trap 'rm -f "$CONF"' EXIT
cat > "$CONF" <<EOF
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
CN = $IP
[v3]
subjectAltName = IP:$IP
EOF

openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout "$DIR/bgrc-ip.key" -out "$DIR/bgrc-ip.crt" \
  -config "$CONF"

chmod 600 "$DIR/bgrc-ip.key"
echo "Wrote $DIR/bgrc-ip.crt and $DIR/bgrc-ip.key (valid 365 days)"
