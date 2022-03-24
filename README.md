Fresh Debian Install Setup
==========================

This repository contains the scripts and Ansible tasks that automates all the things I do after a fresh Debian installation, such as configuration, packages, desktop look and feel and others.

This utility works for the latest Debian version, at the time of writing, latest version is Debian Bullseye.

There are tags for previous versions:
- `debian_10.11`
- `debian9`

## Steps
Run the `init-setup.sh` script after the fresh installation, you need to be `root` as Debian does not install `sudo` by default unless you set no password to `root`.

```
bash <(wget -q -O- https://raw.githubusercontent.com/sguillen-proyectos/fresh-install-setup/master/init-setup.sh)
```

`init-setup.sh` script will add the public Debian reposistory to `/etc/apt/sources.list`, install `sudo, python-pip, python-setuptools, virtualenv` and `ansible` inside a virtualenv sandbox. After that it wil clone this repository so you can continue with the setup process.

> **Important:** Never trust `wget,curl | sh,/bin/bash` unless you are sure what the script is doing. Read the code and make sure it is not doing something that could be risky for you :).


## Upgrade Guide
Before installing a new version of the distro do the next:
- Rename `~/.config` directory
- Rename `~/.local` directory
- Remove `~/.vscode` directory
- Backup `/etc/passwd` in order to check the user and group ids when creating new users
