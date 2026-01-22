#!/usr/bin/env bash

# Copyright (c) 2021-2026 tteck
# Author: tteck (tteckster) | Co-Author: MickLesk (CanbiZ)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://caddyserver.com/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  debian-keyring \
  debian-archive-keyring \
  apt-transport-https
msg_ok "Installed Dependencies"

msg_info "Installing Caddy"
setup_deb822_repo \
  "caddy" \
  "https://dl.cloudsmith.io/public/caddy/stable/gpg.key" \
  "https://dl.cloudsmith.io/public/caddy/stable/deb/debian" \
  "any-version"
$STD apt install -y caddy
msg_ok "Installed Caddy"

read -r -p "${TAB3}Would you like to install xCaddy Addon? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
  setup_go
  fetch_and_deploy_gh_release "xcaddy" "caddyserver/xcaddy" "binary"

  msg_info "Setup xCaddy"
  $STD apt install -y git
  $STD xcaddy build --with github.com/caddy-dns/cloudflare
  msg_ok "Setup xCaddy"
fi

msg_info "Installing Cloudflared"
setup_deb822_repo \
  "cloudflared" \
  "https://pkg.cloudflare.com/cloudflare-main.gpg" \
  "https://pkg.cloudflare.com/cloudflared/" \
  "any" \
  "main"
$STD apt install -y cloudflared
msg_ok "Installed Cloudflared"

read -r -p "${TAB3}Would you like to configure cloudflared as a DNS-over-HTTPS (DoH) proxy? <y/N> " prompt
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  msg_info "Creating Service"
  cat <<EOF >/usr/local/etc/cloudflared/config.yml
proxy-dns: true
proxy-dns-address: 0.0.0.0
proxy-dns-port: 53
proxy-dns-max-upstream-conns: 5
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
  #- https://8.8.8.8/dns-query
  #- https://8.8.4.4/dns-query
  #- https://9.9.9.9/dns-query
  #- https://149.112.112.112/dns-query
EOF
  cat <<EOF >/etc/systemd/system/cloudflared.service
[Unit]
Description=cloudflared DNS-over-HTTPS (DoH) proxy
After=syslog.target network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/cloudflared --config /usr/local/etc/cloudflared/config.yml
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
  systemctl enable -q --now cloudflared
  msg_ok "Created Service"
fi

motd_ssh
customize
cleanup_lxc
