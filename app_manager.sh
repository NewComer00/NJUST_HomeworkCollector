#!/bin/bash
#
# The script to start or restart the app.
# This script should be placed in the root dir of the project.

set -e

# absolute path this script is in
export APP_ROOT=$(dirname "$(readlink -f "$0")")
# process number for uwgsi multiprocessing, equals (#virtual cores * 2) by default
export PROCESS_NUM=$(expr $(nproc --all) \* 2)

# the <N>th homework assigned by the teacher
export HOMEWORK_NUMBER=1
# the page header
export PAGE_HEADER="2021 云数据管理课程"
# the port Nginx listening
export PORT_NUMBER=8080

app_start()
{
    echo "Starting the App..."
    envsubst '${APP_ROOT},${PORT_NUMBER}' \
        < ${APP_ROOT}/configs/nginx.cfg.template \
        > ${APP_ROOT}/configs/nginx.cfg
    nginx -c ${APP_ROOT}/configs/nginx.cfg
    supervisord -c ${APP_ROOT}/configs/supervisord.cfg
    supervisorctl -c ${APP_ROOT}/configs/supervisord.cfg start all
    echo "App started successfully!"
}

app_stop()
{
    #TODO
    # NOTICE:
    # ALL variables are of DEFAULT values here (especially those in cfg files, but except nginx.cfg).
    # ALL customized values are LOST UNLESS SPECIFIED in cmdline.
    # EDIT WITH CAUTION!!!

    echo "Stopping the App..."
    supervisorctl -c ${APP_ROOT}/configs/supervisord.cfg stop all
    kill -s SIGTERM "$(cat ${APP_ROOT}/logs/supervisord/supervisord.pid)"
    nginx -c ${APP_ROOT}/configs/nginx.cfg -s stop
    rm -f ${APP_ROOT}/configs/nginx.cfg
    echo "App stopped successfully!"
}

app_restart()
{
    app_stop
    app_start
}

usage()
{
    printf '\nUsage: %s [OPTIONS] COMMAND\n' "$0"
    printf '\n\t%s\n\n' "Manage Web App by COMMAND with OPTIONS."
    printf 'Example:\n\t%s -n 0 -b "Test" -p 8081 start\n\n' "$0"
    printf '%s\n' "OPTIONS:"
    printf '\t%s\t\t%s\n' "-n --number [N]" "The <N>th homework submission (Default: 1)"
    printf '\t%s\t\t%s\n' "-b --header [HEADER]" "The header of the webpage (Default: '2021 云数据管理课程')"
    printf '\t%s\t\t%s\n' "-p --port [PORT]" "The TCP port this App is on (Default: 8080)"
    printf '\t%s\t\t%s\n' "-h --help" "Show this help message"
    printf '%s\n' "COMMAND:"
    printf '\t%s\t\t%s\n' "start" "Start the App"
    printf '\t%s\t\t%s\n' "stop" "Stop the App"
    printf '\t%s\t\t%s\n' "restart" "Restart the App"
    printf '\t%s\t\t%s\n' "help" "Show this help message"
}

mkdir -p ${APP_ROOT}/logs/nginx
mkdir -p ${APP_ROOT}/logs/supervisord
mkdir -p ${APP_ROOT}/logs/supervisorctl
mkdir -p ${APP_ROOT}/logs/uwsgi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        start) app_start ;;
        stop) app_stop ;;
        restart) app_restart ;;
        help) usage ;;
        -n|--number) HOMEWORK_NUMBER="$2"; shift ;;
        -b|--header) PAGE_HEADER="$2"; shift ;;
        -p|--port) PORT_NUMBER="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
    esac
    shift
done
