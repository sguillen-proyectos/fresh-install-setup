#!/bin/bash

# This script loads all shell scripts from the ~/.my-shell-confs
# direcotyr so the .bashrc directory can be kept clean :)

for config_file in $(ls -1 ~/.my-bash-confs); do
    source ~/.my-bash-confs/$config_file
done
