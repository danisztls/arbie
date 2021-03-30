# Automatic Robust Backup

- [Automatic Robust Backup](#automatic-robust-backup)
  - [About](#about)
    - [Goals](#goals)
    - [Tools](#tools)
  - [Considerations](#considerations)
    - [Security](#security)
    - [For each their own](#for-each-their-own)
    - [Cloud synchronization](#cloud-synchronization)
    - [Granularity](#granularity)
    - [System backup](#system-backup)
    - [Task automation](#task-automation)
  - [Setup](#setup)
    - [Install files](#install-files)
    - [Configure ARB](#configure-arb)
      - [Setup tools](#setup-tools)
      - [Init Git in System repository](#init-git-in-system-repository)
      - [Init Borg repository](#init-borg-repository)
      - [Insert a password in pass](#insert-a-password-in-pass)
      - [Init gocryptfs in reverse mode in a repository](#init-gocryptfs-in-reverse-mode-in-a-repository)
      - [Configure rclone streams](#configure-rclone-streams)
  - [Utils](#utils)
    - [Borg](#borg)
      - [Show info](#show-info)
      - [List archives](#list-archives)
      - [Mount an archive in FUSE](#mount-an-archive-in-fuse)

## About
Automatic Robust Backup or A.R.B. is an archiving and synchronization tool with automation, encryption, performance and redundancy as it goals.

- **Automation**: after configuration it should not require intervention.
- **Encryption**: man-in-the-middle or server should not be able to read the data content.
- **Performance**: tasks should be done in a timely manner and conserve limited resources like size when possible.
- **Redundancy**: data should not be lost even if a catastrophic failure happens.

### Dependencies
- **Borg** is the most popular chunk-based deduplicated backup manager for home users.
- **Gocryptfs** is a spiritual successor to Ecryptfs, it is a mature,audited and has active development.
- **Rclone** is a mature command line cloud storage manager that supports most if not all common providers.
- **Rsync** is the best way to sync a directory to another local or network directory.
- **Git** is the popular version control system.
- **Pass** is the standard UNIX password manager.

## Setup
### Install
`./setup install`

### Configure
Edit `.config/arb/config` to set up your archiving pipelines. Examples for system and home archiving included.

### Init
Some of the tools require manual initialization or configuration. 

#### Init Git in System repository
`git -C "$system_repo" init`

#### Init Borg repository
`borg init -e none "$name_repo"`

#### Insert a password in pass
`pass insert $name`

#### Init gocryptfs in reverse mode in a repository
`gocryptfs -extpass pass -extpass $name_pass -init -reverse "$name_repo"`

#### Configure rclone streams
`rclone config`

## Extra
### Borg
Export the repository path before anything else:

`export BORG_REPO="$name_repo"`

#### Show info
`borg info`

#### List archives
`borg list`

#### Mount an archive in FUSE
`borg mount ::archiveName mountPoint`

## Caveats
### Security
Security is a big concern. **Rclone** and **Borg** have their own encryption features but following the principle of do one thing and do it well **Gocrypts** is exclusively an audited encryption file system.

*Note: The repeated header pattern of **Borg** files may be a vector for a sophisticated attack.*

### For each their own
There is no ideal backup method. But for most users their data can be classified in an ABC fashion: few files that they really can't lose; data with average volume and importance; voluminous but not important data. And each of these categories will have their own ideal methods.

### Cloud synchronization
Cloud providers are a cheap way to have an off-site copy replicated in data centers globally. Some people may have a limited Internet connection and may find useful to instead sync a secondary archive with higher compression and heavy use of exclusion patterns while syncing a full archive on premise.

### Granularity
File-based is simpler but the controlled granularity of chunk-based is ideal. To sync a few large size files would be a PITA because any modification would require a re-upload of the whole file. On the other side to sync a great number of small files directly would congest the API requests quota. **Borg** allows tuning the chunk size and is performant.

### System backup
Reinstalling is faster and saner than doing whole disk backups. It's more practical to backup the system configurations and a list of installed packages. After a fresh minimal install the user can run a script to recover the system settings. The advantages are: no need to restart; instantly done; no voluminous disk images or tar archives; high-granularity history of system changes.

### Task automation
Desktops generally don't stay on 24/7 so there's a need for a tool that will reschedule missed tasks. **Anacron** does that but unfortunately it would require the scripts to run as root. While **Systemd** allows the scripts to run in the user environment and provides it's own logging feature through **Journalctl**. Also many distros are coming only with **Systemd** installed.
