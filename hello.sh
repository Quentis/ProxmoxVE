#!/usr/bin/env bash

# Define colors for output
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
BGN=$(echo "\033[4;64m")
GN=$(echo "\033[1;92m")
DGN=$(echo "\033[32m")
CL=$(echo "\033[m")

echo -e "${GN}SUCCESS!${CL}"
echo -e "${BL}You have successfully executed a script from your fork.${CL}"
echo -e "Repository: ${YW}https://raw.githubusercontent.com/Quentis/ProxmoxVE/test/hello.sh${CL}"
echo -e "Time: $(date)"