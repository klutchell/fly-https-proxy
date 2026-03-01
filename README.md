# https-proxy-fly

Lightweight HTTPS forward proxy on Fly.io using tinyproxy.
Useful as `HTTPS_PROXY` to route traffic through a different
egress IP/region.

## Architecture

```text
Client (HTTPS_PROXY=https://user:pass@app.fly.dev)
  → Fly.io edge (TLS termination, port 443)
    → tinyproxy :8888 (BasicAuth + IP allowlist)
      → CONNECT tunnel to destination
```

## Environment Variables

| Variable | Source | Description |
| -------- | ------ | ----------- |
| `PROXY_USER` | `fly secrets` | Basic auth username |
| `PROXY_PASS` | `fly secrets` | Basic auth password |
| `ALLOWED_IPS` | `fly secrets` | Comma-separated IP allowlist |
| `LOG_LEVEL` | `fly.toml [env]` | tinyproxy log level (default: `Connect`) |

## Deploy

```sh
cp fly.toml.example fly.toml
# Edit fly.toml: set app name and region

fly apps create your-app-name
fly secrets set PROXY_USER=myuser PROXY_PASS=mypass
fly deploy
# Decline dedicated IPs when prompted, then allocate shared IPs:
fly ips allocate-v4 --shared
fly ips allocate-v6
# Fly creates 2 machines by default for HA; scale to 1 if not needed:
fly scale count 1
```

## Test

### Local

```sh
docker compose -f docker-compose.test.yml up --build --abort-on-container-exit
```

### Remote

```sh
curl -sf --proxy https://user:pass@your-app-name.fly.dev:443 https://httpbin.org/ip
```

## Usage

Set `HTTPS_PROXY` on your remote application to route outbound
HTTPS traffic through the proxy:

```sh
HTTPS_PROXY=https://user:pass@your-app-name.fly.dev:443
```

Most HTTP clients (curl, Python requests, Node.js, etc.) respect
this variable automatically. Some applications may use
`https_proxy` (lowercase) instead.

## Cost

With `auto_stop_machines = 'suspend'` and a shared IPv4, the
machine suspends when idle and only runs while handling traffic.

| Component | Cost |
| --------- | ---- |
| Shared IPv4 + IPv6 | Free |
| VM (suspended) | ~$0.15/GB/mo rootfs |
| VM (running) | ~$2.32/mo if 24/7 |

Typical cost for intermittent traffic: **under $1/mo**.

## Development

```sh
nix develop  # provides flyctl
```
