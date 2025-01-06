#!/bin/bash

postproc() {
  echo "terminating..."

  pids=$(jobs -p)
  [ -n "$pids" ] && kill $pids

  if [ -e "/etc/init.d/pcscd" ]; then
    echo "stopping pcscd..."
    /etc/init.d/pcscd stop
    sleep 1
  fi

  exit
}

trap postproc INT TERM EXIT

if [ -e "/etc/init.d/pcscd" ]; then
  while :; do
    echo "starting pcscd..."
    /etc/init.d/pcscd start
    sleep 1
    timeout 2 pcsc_scan | grep -A 50 "Using reader plug'n play mechanism"
    if [ $? = 0 ]; then
      break;
    fi
    echo "failed!"
  done
fi

echo "starting b25-server..."
b25-server &

echo "starting mirakc..."
/usr/local/bin/mirakc
