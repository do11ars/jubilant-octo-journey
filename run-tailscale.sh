#!/usr/bin/env bash
set -e

# 1. Jalankan Tailscale
/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
TAILSCALED_PID=$!

# 2. Hubungkan Tailscale
until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}"; do
  sleep 0.5
done
echo "Tailscale is up."

# 3. BUAT TUNNEL SPESIFIK UNTUK DATABASE (Alternatif ProxyChains)
# Ini akan memetakan localhost:5432 di dalam container ke 100.75.146.49:5432 di Tailscale
# Lewat SOCKS5 Tailscale (1055)
gost -L tcp://:5432/100.75.146.49:5432 -F socks5://127.0.0.1:1055 &
GOST_PID=$!

# 4. Tunggu sebentar agar tunnel siap
sleep 2
echo "Tunnel database siap di localhost:5432"

# 5. Jalankan Vaultwarden
# PENTING: Ubah DATABASE_URL Anda di Render menjadi:
# postgresql://user:password@localhost:5432/dbname
export ROCKET_ADDRESS=0.0.0.0
/vaultwarden &
VAULT_PID=$!

wait -n ${TAILSCALED_PID} ${GOST_PID} ${VAULT_PID}
