#!/usr/bin/env bash

quiet=false
option=

function quit() {
    unset quiet option
    exit $1
}

function print_usage() {
    printf "Usage:\n"
    printf "\tinstall.sh [OPTIONS]\n\n"

    printf "Options:\n"
    printf "\t-h,--help\t\tPrints this message.\n"
    printf "\t-q,--quiet\t\tDo not print command output.\n"
    printf "\t-i,--apt-install\tInstalls the APT version of xRDP. This is the default.\n"
    printf "\t-I,--cnergy-install\tInstalls the C-Nergy version of xRDP.\n"
    printf "\t-c,--fix-closing\tFixes immediate closing of RDP.\n"
    printf "\t-b,--fix-browsers\tFixes browsers inside of RDP.\n"
}

function run_command() {
    local command=$1

    if $quiet; then
        $command &> /dev/null
    else
        $command
    fi
}

function apt_install() {
    printf "\e[1mUpdating APT...\e[0m\n"
    run_command "sudo apt update"
    printf "\e[1mInstalling xRDP via APT...\e[0m\n"
    run_command "sudo apt install xrdp -y"
    printf "\e[1mEnabling and starting xRDP...\e[0m\n"
    run_command "sudo systemctl enable xrdp --now"
    printf "\e[1mAdding $USER to proper groups...\e[0m\n"
    run_command "sudo usermod -aG xrdp,ssl-cert $USER"
}

function cnergy_install() {
    printf "\e[1mDownloading C-Nergy script archive...\e[0m\n"
    run_command "wget -O /tmp/xrdp-installer-1.4.zip https://www.c-nergy.be/downloads/xRDP/xrdp-installer-1.4.zip"
    printf "\e[1mExtracting C-Nergy script archive...\e[0m\n"
    run_command "unzip -d /tmp /tmp/xrdp-installer"
    printf "\e[1mEnabling C-Nergy script for execution...\e[0m\n"
    chmod +x /tmp/xrdp-installer-1.4.sh
    printf "\e[1mRunning C-Nergy script...\e[0m\n"
    run_command "/tmp/xrdp-installer-1.4.sh"
    printf "\e[1mAdding $USER to proper groups...\e[0m\n"
    sudo usermod -aG xrdp,ssl-cert $USERW
}

function fix_closing() {
    printf "\e[1mFixing immediate close issue...\e[0m\n"
    sudo sed -i 's/--what=handle-power-key/--what=idle/g' /usr/bin/x-session-manager
    printf "\e[1mRestarting xRDP...\e[0m\n"
    sudo systemctl restart xrdp
}

function fix_browsers() {
    printf "\e[1mFixing browsers...\e[0m\n"
    sudo sed -i 's/Option "DRMDevice" "[^"]\+"/Option "DRMDevice" ""/g' /etc/X11/xrdp/xorg.conf
    printf "\e[1mRestarting xRDP...\e[0m\n"
    sudo systemctl restart xrdp
}

while [[ $1 =~ ^--? ]]; do
    option=$1
    if [[ $option == -h || $option == --help ]]; then
        print_usage
        quit 0
    elif [[ $option == -q || $option == --quiet ]]; then
        quiet=true
    elif [[ $option == -i || $option == --apt-install ]]; then
        apt_install
        quit $?
    elif [[ $option == -I || $option == --cnergy-install ]]; then
        cnergy_install
        quit $?
    elif [[ $option == -c || $option == --fix-closing ]]; then
        fix_closing
        quit $?
    elif [[ $option == -b || $option == --fix-browsers ]]; then
        fix_browsers
        quit $?
    fi  
    shift
done

print_usage > /dev/stderr
quit 1