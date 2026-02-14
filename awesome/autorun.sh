#!/usr/bin/env bash
function run {
  if ! pgrep -f $1; then
    $@ &
  fi
}

picom --config ~/os_customisation/picom/picom.sample.conf --backend xrender --daemon
