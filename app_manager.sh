#!/bin/bash
#
# The script to start or restart the app.
# This script should be placed in the root dir of the project.

set -e

# absolute path this script is in
export APP_ROOT=$(dirname "$(readlink -f "$0")")
# the <N>th homework assigned by the teacher
export HOMEWORK_NUMBER=1

app_start()
{
    envsubst '${APP_ROOT}' < ${APP_ROOT}/configs/nginx.cfg.template > ${APP_ROOT}/configs/nginx.cfg
    nginx -c ${APP_ROOT}/configs/nginx.cfg
    supervisord -c ${APP_ROOT}/configs/supervisord.cfg
    supervisorctl -c ${APP_ROOT}/configs/supervisord.cfg reload
}

app_stop()
{
    supervisorctl -c ${APP_ROOT}/configs/supervisord.cfg stop all
    kill -s SIGTERM "$(cat ${APP_ROOT}/logs/supervisord/supervisord.pid)"
    nginx -c ${APP_ROOT}/configs/nginx.cfg -s stop
    rm -f ${APP_ROOT}/configs/nginx.cfg
}

app_reload()
{
    supervisorctl -c ${APP_ROOT}/configs/supervisord.cfg reload
}


mkdir -p ${APP_ROOT}/logs/nginx
mkdir -p ${APP_ROOT}/logs/supervisord
mkdir -p ${APP_ROOT}/logs/supervisorctl
mkdir -p ${APP_ROOT}/logs/uwsgi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        start) app_start ;;
        stop) app_stop ;;
        reload) app_reload ;;
        -n|--number) HOMEWORK_NUMBER="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done
