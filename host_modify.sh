#!/bin/bash

SITES="old.reddit.com www.reddit.com www.imgur.com imgur.com www.youtube.com youtube.com"

function block_host() {
  this_site=$1
  sed -rin /^\#127.0.0.1\\t"$this_site"/s//127.0.0.1\\t"$this_site"/ /etc/hosts
  echo "Blocking $this_site"
}
function unblock_host() {
  this_site=$1
  sed -rin /^\#127.0.0.1\\t"$this_site"/s//127.0.0.1\\t"$this_site"/ /etc/hosts
  echo "Blocking $this_site"
}

if [ "$1" == "block" ]; then
  for SITE in $SITES; do
    block_host "$SITE"
  done
  if [[ "$2" != "" ]] && [[ "$2" =~ ^[0-9]+$ ]] && [[ "$2" -gt 0 ]] ; then
    echo "For $2 Seconds"
    sleep "$2"
    for SITE in $SITES; do
      unblock_host "$SITE"
    done
  fi
elif [ "$1" == "unblock" ]; then
  for SITE in $SITES; do
    unblock_host "$SITE"
  done
  if [[ "$2" != "" ]] && [[ "$2" =~ ^[0-9]+$ ]] && [[ "$2" -gt 0 ]] ; then
    echo "For $2 Seconds"
    sleep "$2"
    for SITE in $SITES; do
      block_host "$SITE"
    done
  fi
else
  echo "$0 requires argument [block|unblock]"
fi

