# Automatic Robust Backup

Automatic Robust Backup or A.R.B. is an archiving and synchronization tool with automation, encryption, redundancy and performance as it goals. It is fast to deploy and provides pre-built use cases and sensible defaults. It is declarative and easy to customize.

## About

### Goals

- **Automation**: after configuration it should not require intervention.
- **Encryption**: man-in-the-middle or server should not be able to read the data content.
- **Redundancy**: data should not be lost even if a catastrophic failure happens.
- **Performance**: tasks should be done in a timely manner and conserve limited resources like size when possible.

### Dependencies

- [Borg](https://github.com/borgbackup/borg), the most popular chunk-based deduplication backup manager for home users.
- [Gocryptfs](https://github.com/rfjakob/gocryptfs), the spiritual successor to Ecryptfs that is mature, audited actively developed.
- [Rclone](https://github.com/rclone) is a mature command line cloud storage manager that supports most if not all common providers.
- [Rsync](https://github.com/WayneD/rsync) is the best way to sync a directory to another local or network directory.
- [Git](https://github.com/git/git) is the most popular version control system.
- [Pass](https://www.passwordstore.org/), the standard UNIX password manager, or [gopass](https://github.com/gopasspw/gopass), its actively developed Go fork.

### Features

- Save space via Borg's fast and effective deduplication and compression.
- Do daily, or even more granular, archives and mount them wherever you want to check the repository at that time.
- Set complex retention policies to control repository size while preserving time span coverage.
- Ensure privacy and integrity of data stored on cloud through Gocryptfs online encryption.
- Sync your data to over 40 cloud storage services, including all major providers with free tiers _(Google Drive, Dropbox, Onedrive, Mega, etc)_.
- Store secrets encrypted with GPG key and Git versioned.
- Archive system configuration files and package list.
- Archive your personal files and whatever files you wish.

## Install

### Packages

- [Arch Linux](https://aur.archlinux.org/packages/arbie-git/)

### Make

```sh
make
make install
```

## Configure

### Pipelines

Edit `.config/arbie/config` to set up pipelines. Instructions and examples included in the file.

### Init

Some of the tools require manual initialization or configuration. In the future there will be a tool to partially automate those.

#### Pass

Init a password repository

```sh
gopass setup
```

_Note: A GPG key is needed._

Generate a long secure password

```sh
pass generate $secret_name
```

Insert a password manually

```sh
pass insert $secret_name
```

_Note: They will be needed later for encryption._

#### System

Init Git in System repository

```sh
git -C $repo_path init
```

#### Borg

Init Borg repository

```sh
$borg init -e none $repo_path
```

_Note: Encryption is done by gocryptfs._

#### Gocryptfs

Init reverse mode encryption in a dir

```sh
gocryptfs -extpass pass -extpass $secret_name -init -reverse $repo_path
```

_Note: Reverse mode encryption mount plain dir and files as encrypted files with encrypted dir names which is ideal for storing on the cloud._

#### Rclone

Configure streams

```sh
rclone config
```

### Service

Enable the systemd timer as user

```sh
systemctl --user enable arbie.timer
```

By default it will try to run daily at midnight and run immediately after login in case of a miss. But you edit the service to make it run whenever you want by using a cron alike syntax.

```sh
systemctl --user edit arbie.timer
```

More information about that on [Arch Wiki: Systemd/Timers](https://wiki.archlinux.org/index.php/Systemd/Timers)

## Maintenance

### Borg

Before anything, export the repository path.

```sh
export BORG_REPO="$repo_path"
```

Show repository info

```sh
borg info
```

List archives

```sh
borg list
```

Mount an archive with FUSE

```sh
borg mount ::archiveName mountPoint
```

## Caveats

### Security

Security is a big concern. **Rclone** and **Borg** have their own encryption features but following the principle of do one thing and do it well **Gocrypts** is exclusively an audited encryption file system.

_Note: The repeated and thus predictable header pattern of Borg files may be a vector for a sophisticated attack._

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
