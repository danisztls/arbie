#!/bin/bash
# CONF
share=$HOME/.local/share/arb
systemd=$HOME/.config/systemd/user

script=$(readlink -f $0) # absolute script path
src=`dirname "$script"` # absolute source files path

deps=(borg git gocryptfs pass rclone rsync) # dependencies

installMany() {
    toInstall=()
    for pkg; do pacman -Qi $pkg &> /dev/null || toInstall+=("${pkg}"); done # select pkgs not already installed
    [[ "${toInstall[@]}" == "" ]] || ( sudo pacman -Syu && sudo pacman -S "${toInstall[@]}" ) # install select pkgs if any
}

if [ "$#" -ne 1 ]; then # HELP
    echo "Options are install and uninstall." && exit 1
fi

if [ "$1" == install ]; then # INSTALL
    installMany "${deps[@]}" # install pkgs
    mkdir -p $share && rsync -r --exclude={'arb.timer','arb.service','.git','.gitignore'} $src/ $share/ # copy program files
    mkdir -p $systemd && cp "$src/arb.service" $systemd/ && cp "$src/arb.timer" $systemd/ && systemctl --user daemon-reload # setup systemd
    exit 0
fi

if [ "$1" == unistall ]; then # UNINSTALL
    rm -rf $share # remove program files
    systemctl --user stop arb && systemctl --user disable arb && systemctl --user disable arb.timer # disable arb
    rm -f "$systemd/arb.service" && rm -f "$systemd/arb.timer" && systemctl --user daemon-reload # remove from systemd
    exit 0
fi
