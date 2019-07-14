#!/bin/bash

function log() {
    time=`date "+%F %T"`
    log_level=$1
    msg=$2
    color=$3
    echo -e "${time} - ${color}[${log_level}]\e[0m - ${msg}"
}

function info() {
    log INFO "$1" '\e[38;5;82m'
}

function error() {
    log ERROR "$1" '\e[31m'
}

LOG_DIR=/var/log/fresh-debian/
INSTALL_DIR=/opt/fresh-install-setup
GIT_REPO=https://github.com/sguillen-proyectos/fresh-install-setup.git

function comment_existing_repositories() {
    sed -i.bak 's/^deb/# deb/g' /etc/apt/sources.list
}

function add_debian_repository() {
    comment_existing_repositories

    REPO='deb http://deb.debian.org/debian/ buster main contrib non-free'
    echo ${REPO} >> /etc/apt/sources.list
}

function install_ansible() {
    if [[ ! -d ${INSTALL_DIR} ]]; then
        error "Cannot find the ${INSTALL_DIR} directory"
        exit 1
    fi
    virtualenv ${INSTALL_DIR}/env
    source ${INSTALL_DIR}/env/bin/activate
    pip install ansible >> ${LOG_DIR}/ansible.log 2>&1
}

function install_basic_packages() {
    apt update > ${LOG_DIR}/apt.log 2>&1

    packages='sudo git python-pip python-setuptools'
    info "Installing ${packages} ..."
    apt install -y ${packages} >> ${LOG_DIR}/apt.log 2>&1

    pip install virtualenv > ${LOG_DIR}/ansible.log 2>&1
}

function basic_setup() {
    mkdir -p ${LOG_DIR}

    info 'Adding public Debian repository'
    add_debian_repository

    info "Installing basic packages"
    install_basic_packages

    info "Cloning fresh-install-setup at ${INSTALL_DIR}"
    if [[ -d $INSTALL_DIR ]]; then
        rm -rf $INSTALL_DIR
    fi
    git clone "${GIT_REPO}" ${INSTALL_DIR}

    info "Installing Ansible in ${INSTALL_DIR}/env"
    install_ansible

    read -ep 'Type username for which changes will take place: ' INSTALLATION_USER

    source ${INSTALL_DIR}/env/bin/activate
    cd ${INSTALL_DIR}

    ansible-playbook -i inventory setup-playbook.yml --extra-vars ansible_user=${INSTALLATION_USER}

    read -ep 'Add user to sudo group? [yes/no] ' ADD_TO_SUDO
    if [[ ${ADD_TO_SUDO} == 'yes' ]]; then
        read -ep 'Type the username to add to sudo group: ' NEW_SUDO_USER
        gpasswd -a ${NEW_SUDO_USER} sudo
        if [[ $? == '0' ]]; then
            info "${NEW_SUDO_USER} added to sudo group"
            read -ep 'Do you want to reboot before continue? [yes/no] ' REBOOT_COMPUTER

            if [[ ${REBOOT_COMPUTER} == 'yes' ]]; then
                info "Rebooting machine"
                reboot
            fi
        else
            error "Could not add ${NEW_SUDO_USER} to sudo group"
        fi
    fi

    echo -e "\e[1;30;42m Installation process finished successfully! \e[0m"
    echo "Run the /opt/update-desktop-layout.sh script with your normal user, DO NOT USE ROOT for that."
    echo "     $ bash ${INSTALL_DIR}/update-desktop-layout.sh"
    echo "After that, you might want to reboot your computer."
}

if [[ "${UID}" != '0' ]]; then
    error "You must be root in order to execute this script"
    exit 1
fi

basic_setup
