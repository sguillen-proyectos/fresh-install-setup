#!/bin/bash

function log() {
    time=`date "+%F %T"`
    log_level=$1
    msg=$2
    echo "${time} - [${log_level}] - ${msg}"
}

function info() {
    log INFO "$1"
}

function error() {
    log ERROR "$1"
}

LOG_DIR=/var/log/fresh-debian/

function comment_existing_repositories() {
    sed -i.bak 's/^deb/# deb/g' /etc/apt/sources.list
}

function add_debian_repository() {
    comment_existing_repositories

    REPO='deb http://deb.debian.org/debian/ stretch main contrib non-free'
    echo ${REPO} >> /etc/apt/sources.list
}

function install_ansible() {
    virtualenv /opt/env
    source /opt/env/bin/activate
    pip install ansible >> ${LOG_DIR}/ansible.log 2>&1
}

function install_basic_packages() {
    apt update > ${LOG_DIR}/apt.log 2>&1
    apt install -y sudo python-pip python-setuptools >> ${LOG_DIR}/apt.log 2>&1

    pip install virtualenv > ${LOG_DIR}/ansible.log 2>&1
}

function basic_setup() {
    mkdir -p ${LOG_DIR}

    info 'Adding public Debian repository'
    add_debian_repository

    info "Installing basic packages"
    install_basic_packages

    info "Installing Ansible"
    install_ansible
}

if [[ "${UID}" != '0' ]]; then
    error "You must be root in order to execute this script"
    exit 1
fi

basic_setup
