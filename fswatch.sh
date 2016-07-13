#!/usr/bin/env bash
set -e
cd $UNISON_DIR
cmd="fswatch ${FSWATCH_EXCLUDES} -orIE ${UNISON_DIR} | xargs -I -n1 unison $UNISON_EXCLUDES \"$UNISON_DIR\" -auto -batch -owner -numericids socket://${HOST_IP}:${UNISON_HOST_PORT}"
echo $cmd
eval $cmd
