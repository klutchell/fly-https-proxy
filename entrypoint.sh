#!/bin/sh
set -eu

CONF="/tmp/tinyproxy.conf"

cat /etc/tinyproxy/tinyproxy.conf > "$CONF"

echo "LogLevel ${LOG_LEVEL:-Connect}" >> "$CONF"

if [ -n "${PROXY_USER:-}" ] && [ -n "${PROXY_PASS:-}" ]; then
    echo "BasicAuth ${PROXY_USER} ${PROXY_PASS}" >> "$CONF"
fi

if [ -n "${ALLOWED_IPS:-}" ]; then
    echo "$ALLOWED_IPS" | tr ',' '\n' | while read -r ip; do
        ip=$(echo "$ip" | tr -d '[:space:]')
        [ -n "$ip" ] && echo "Allow ${ip}" >> "$CONF"
    done
else
    echo "Allow 0.0.0.0/0" >> "$CONF"
fi

exec tinyproxy -d -c "$CONF"
