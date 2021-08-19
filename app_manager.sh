#!/bin/bash
#
# The script to start or restart the app.
# This script should be placed in the root dir of the project.

set -e

# absolute path this script is in
export APP_ROOT=$(dirname "$(readlink -f "$0")")
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
    # ALL variables are of DEFAULT values here (include those in CONFIG files).
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

mkdir -p ${APP_ROOT}/logs/nginx
mkdir -p ${APP_ROOT}/logs/supervisord
mkdir -p ${APP_ROOT}/logs/supervisorctl
mkdir -p ${APP_ROOT}/logs/uwsgi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        start) app_start ;;
        stop) app_stop ;;
        restart) app_restart ;;
        -n|--number) HOMEWORK_NUMBER="$2"; shift ;;
        -b|--header) PAGE_HEADER="$2"; shift ;;
        -p|--port) PORT_NUMBER="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done
