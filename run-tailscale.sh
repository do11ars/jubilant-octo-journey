#!/usr/bin/env bash

# 1. Jalankan Tailscale daemon dengan penyimpanan state di memori
# --state=mem: penting agar tidak error saat menulis file di Render
/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --state=mem: &
TAILSCALED_PID=$!

# 2. Hubungkan ke Tailscale
echo "Menghubungkan ke Tailscale..."
/render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}"

# Tunggu sampai Tailscale benar-benar aktif (Running)
until /render/tailscale status | grep -q "linux   active"; do
  echo "Menunggu Tailscale aktif..."
  sleep 2
done

# Pastikan port SOCKS5 sudah terbuka
until nc -zv localhost 1055; do
  echo "Menunggu port SOCKS5 (1055) siap..."
  sleep 1
done

echo "Tailscale siap! IP: $(/render/tailscale ip -4)"

# 3. Jalankan Vaultwarden menggunakan proxychains
echo "Memulai Vaultwarden melalui ProxyChains..."

# Menggunakan 'exec' agar Vaultwarden menjadi proses utama (PID 1)
# Ini membantu stabilitas di platform cloud seperti Render
exec proxychains4 /vaultwarden
