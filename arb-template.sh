#!/bin/bash
# A.R.B. Automatic Robust Backup

function umountCrypt() { # umountCrypt
    ([[ -d "$2" ]] && fusermount -uz "$mount") || (echo "`date +"[%b %d %H:%M:%S]"` error: unmounting "$mount" failed"; return 1)
    [[ -n "$(ls -A "$mount")" ]] || rm -r "$mount" # remove dir
}

function mountCrypt() { # mountCrypt $src $mount_point $pass $exclude (optional)
    [[ -d "$2" ]] && [[ -n "$(ls -A "$2")" ]] && (echo "`date +"[%b %d %H:%M:%S]"` warning: "$2" is already mounted, unmounting..."; (umountCrypt && sleep 2) || return 1) # unmount if already mounted
    mkdir -p "$2" # make dir if inexistent
    [ "$4" ] && gocryptfs -extpass pass -extpass $3 -exclude-from "$4" -reverse "$1" "$2" ||
    gocryptfs -extpass pass -extpass $3 -reverse "$1" "$2" # mount reverse encrypted
}

function syncDisk() { # syncDisk $src $dst
    rsync -a --delete "$1" "$2"
}

function syncCloud() { # syncCloud $name $src $stream
    echo "`date +"[%b %d %H:%M:%S]"` sync: syncing $1 to $3"
    rclone sync -u --use-server-modtime --skip-links --fast-list --max-backlog=-1 "$2/" $3:$1/
}

function archiveSys() { # archiveSys $repo $exclude
    mkdir -p "$1" # make dir if inexistent
    pacman -Qqen > "$1/pkglist.txt" # export non-local pkg list
    pacman -Qqem > "$1/pkglist-local.txt" # export local pkg list
    export CVSIGNORE="$2" && rsync -qaH --delete -C /etc/ "$1/etc/" # sync /etc
    git -C "$1" add -A && git -C "$1" commit -m `date +%Y-%m-%d` # archive changes in git
}

function archiveBorg() { # archiveBorg $borg_repo $borg_exclude $src $borg_pass (optional) $borg_key (optional)
    export BORG_REPO="$1"
    [ $4 ] && export BORG_PASSCOMMAND="pass $4" && [ $5 ] && export BORG_KEY_FILE="$5"
    borg create -s -x -C lz4 --exclude-from "$2" ::{user}-{now:%y-%m-%d} "$3" # archive
    borg prune --list --keep-daily=7 --keep-weekly=4 # purge old
}

function archiveBorgLite() { # archiveBorg $borg_repo $borg_exclude $src $borg_pass (optional) $borg_key (optional)
    export BORG_REPO="$1"
    [ $4 ] && export BORG_PASSCOMMAND="pass $4" && [ $5 ] && export BORG_KEY_FILE="$5"
    borg create -s -x -C auto,lzma --exclude-from "$2" --chunker-params 10,23,16,4095 ::{user}-{now:%y-%m-%d} "$3" # archive with higher compression and fine granularity
    borg prune --list --keep-last=1 # purge old
}

for pid in $(pidof -x arb.sh); do # exit if already being executed
    if [ $pid != $$ ]; then
        echo "`date +"[%b %d %H:%M:%S]"` error: program is already running with PID $pid"
        exit 1
    fi
done

trap ctrl_c INT # clean exit with ctrl+c
ctrl_c() {
    kill -15 $child && wait $child # send SIGTERM to child process
    [ $mount ] && umountCrypt # unmount last mount point
    echo -e "\n`date +"[%b %d %H:%M:%S]"` error: program was manually terminated" && exit 1
}

source "$HOME/.local/share/arb/arb.config" # load config variables

# EDIT BELLOW

# System Archive
echo "`date +"[%b %d %H:%M:%S]"` archive: system archiving started"
archiveSys "$system_repo" "$system_exclude" & child=$! && wait $child
echo "`date +"[%b %d %H:%M:%S]"` archive: system archiving ended"

# Borg Archive
echo "`date +"[%b %d %H:%M:%S]"` archive: repoName borg archiving started"
archiveBorg $name_repo $name_exclude $name_src & child=$! && wait $child
echo "`date +"[%b %d %H:%M:%S]"` archive: repoName borg archiving ended"

# Repo Sync to Disk
echo "`date +"[%b %d %H:%M:%S]"` sync: repoName syncing to disk started"
syncDisk "$name_repo" "$name_rsync" & child=$! && wait $child
echo "`date +"[%b %d %H:%M:%S]"` sync: repoName syncing to disk ended"

# Repo Sync to Cloud
echo "`date +"[%b %d %H:%M:%S]"` sync: repoName encrypted syncing to cloud started"
mount="$repo_crypt" && mountCrypt "$name_repo" "$mount" "$name_pass" || exit 1
for stream in ${name_rclone[@]}; do syncCloud name "$name_repo" $stream & child=$! && wait $child; done
echo "`date +"[%b %d %H:%M:%S]"` sync: repoName encrypted syncing to cloud ended"
