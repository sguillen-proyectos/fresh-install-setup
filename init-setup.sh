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

export DEBIAN_VERSION=${DEBIAN_VERSION:-bookworm}
LOG_DIR=/var/log/fresh-debian/
INSTALL_DIR=/opt/fresh-install-setup
GIT_REPO=https://github.com/sguillen-proyectos/fresh-install-setup.git

function comment_existing_repositories() {
    sed -i.bak 's/^deb/# deb/g' /etc/apt/sources.list
}

function add_debian_repository() {
    comment_existing_repositories

    REPO="deb http://deb.debian.org/debian/ ${DEBIAN_VERSION} main contrib non-free"
    echo ${REPO} >> /etc/apt/sources.list
}

function install_ansible() {
    if [[ ! -d ${INSTALL_DIR} ]]; then
        error "Cannot find the ${INSTALL_DIR} directory"
        exit 1
    fi
    info "Activating virtualenv for ansible installation"
    virtualenv -p python3 ${INSTALL_DIR}/env
    source ${INSTALL_DIR}/env/bin/activate
    info "Installing ansible"
    pip install ansible 2>&1 | tee -a ${LOG_DIR}/ansible.log
}

function install_basic_packages() {
    apt update 2>&1 | tee -a ${LOG_DIR}/apt.log

    packages='sudo git python3-pip python3-setuptools'
    info "Installing ${packages} ..."
    apt install -y ${packages} 2>&1 | tee -a ${LOG_DIR}/apt.log

    info "Installing virtualenv"
    pip3 install virtualenv --break-system-packages 2>&1 | tee -a ${LOG_DIR}/ansible.log
}

function basic_setup() {
    mkdir -p ${LOG_DIR}


    if [[ -z $LOCAL_DEVELOPMENT ]]; then
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
    fi

    if [[ -z $INSTALLATION_USER ]]; then
        read -ep 'Type username for which changes will take place: ' INSTALLATION_USER
    else
        echo "Using \"${INSTALLATION_USER}\" from INSTALLATION_USER environment variable"
    fi

    source ${INSTALL_DIR}/env/bin/activate
    cd ${INSTALL_DIR}

    if [[ -n $LOCAL_DEVELOPMENT ]]; then
        git pull origin master
    fi

    ansible-playbook -i inventory setup-playbook.yml --extra-vars ansible_user=${INSTALLATION_USER} $@

    read -ep "Add ${INSTALLATION_USER} user to sudo group? [yes/no] " ADD_TO_SUDO
    if [[ ${ADD_TO_SUDO} == 'yes' ]]; then
        gpasswd -a ${INSTALLATION_USER} sudo
        if [[ $? == '0' ]]; then
            info "${INSTALLATION_USER} added to sudo group"
        else
            error "Could not add ${INSTALLATION_USER} to sudo group"
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

basic_setup $@
