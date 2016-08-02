#!/usr/bin/env bash
set -e

if [ "$1" == 'supervisor' ]; then

    # Deactivate fswatch if needed
    if [ -z $ENABLE_WATCH ]; then
      mv /etc/supervisor/conf.d/supervisor.fswatch.conf /etc/supervisor/conf.d/supervisor.fswatch.conf.deactivated
    fi

    # see https://wiki.alpinelinux.org/wiki/Setting_the_timezone
    if [ -n ${TZ} ] && [ -f /usr/share/zoneinfo/${TZ} ]; then
        ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
        echo ${TZ} > /etc/timezone
    fi

    # Check if a script is available in /lsyncd-entrypoint.d and source it
    for f in /lsyncd-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *)        echo "$0: ignoring $f" ;;
        esac
    done
fi

exec "$@"
