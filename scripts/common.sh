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

function warning() {
    log WARN "$1"
}
