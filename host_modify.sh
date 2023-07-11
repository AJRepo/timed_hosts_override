#!/bin/bash

SITES="old.reddit.com www.reddit.com www.imgur.com imgur.com www.youtube.com youtube.com"

if [ "$1" == "block" ]; then
  for SITE in $SITES; do
    echo "Blocking $SITE"
    sed -rin /^\#127.0.0.1\\t"$SITE"/s//127.0.0.1\\t"$SITE"/ /etc/hosts
  done
elif [ "$1" == "unblock" ]; then
  for SITE in $SITES; do
    echo "Unlocking $SITE"
    sed -rin /^127.0.0.1\\t"$SITE"/s//\#127.0.0.1\\t"$SITE"/ /etc/hosts 
  done
else
  echo "$0 requires argument [block|unblock]"
fi
