#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Quentis/ProxmoxVE/dev/misc/build.func)
# Copyright (c) 2021-2026 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://caddyserver.com/

APP="lxc-edge-gateway"
var_tags="${var_tags:-webserver;tunnel}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /etc/systemd/system/cloudflared.service ]] || [[ ! -d /etc/caddy ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Updating Caddy LXC"
  $STD apt update
  $STD apt upgrade -y
  msg_ok "Updated Caddy LXC"

  if command -v xcaddy >/dev/null 2>&1; then
    if check_for_gh_release "xcaddy" "caddyserver/xcaddy"; then
      setup_go
      fetch_and_deploy_gh_release "xcaddy" "caddyserver/xcaddy" "binary"
      # Move xcaddy to /usr/bin to have it in PATH
      mv xcaddy /usr/bin/

      msg_info "Updating xCaddy"
      $STD xcaddy build --with github.com/caddy-dns/cloudflare
      msg_ok "Updated xCaddy"
    fi
  fi
  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:80${CL}"
