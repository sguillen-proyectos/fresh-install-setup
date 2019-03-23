Fresh Debian Install Setup
==========================

This repository contains the scripts and Ansible tasks that automates all the things I do after a fresh Debian installation, such as configuration, packages, desktop look and feel and others.

It is tested on Debian Stretch (my current version) and XFCE as desktop environment.

## Steps
Run the `init-setup.sh` script after the fresh installation, you need to be `root` as Debian does not install `sudo` by default unless you set no password to `root`.

```
cd /opt
wget https://raw.githubusercontent.com/sguillen-proyectos/fresh-install-setup/master/init-setup.sh
```

`init-setup.sh` script will add the public Debian reposistory to `/etc/apt/sources.list`, install `sudo, python-pip, python-setuptools, virtualenv` and `ansible` inside a virtualenv sandbox. After that it wil clone this repository so you can continue with the setup process.

> **Important:** Never trust `wget,curl | sh,/bin/bash` unless you are sure what the script is doing. Read the code and make sure it is not doing something that could be risky for you :).
