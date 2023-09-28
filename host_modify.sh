#!/bin/bash

SITES="old.reddit.com www.reddit.com www.imgur.com imgur.com www.youtube.com youtube.com"
USE_PIETIMER="False"

#does pietimer exist?
PIETIMER=$(which countdowntimer.py)
if [ -x "$PIETIMER" ]; then
  USE_PIETIMER="True"
fi


function start_timer() {
  local seconds=$1
  if [[ "$seconds" != "" ]] && [[ "$seconds" =~ ^[0-9]+$ ]] && [[ "$seconds" -gt 0 ]] ; then
    if [ $USE_PIETIMER == "True" ]; then
      if [[ $(whoami) == "root" ]]; then
        #No reason to run the timer as root
        if [[ $SUDO_USER != "" ]]; then
          echo "For $seconds seconds: See gui timer"
          sudo -u "$SUDO_USER" "$PIETIMER" -d -q -s "$seconds"
        else
          echo "Won't run gui timer as root. Exiting."
          exit 1
        fi
        echo "HO"
      fi
    else
      echo "For $seconds seconds"
      sleep "$seconds"
    fi
  fi
}


function block_host() {
  this_site=$1
  sed -rin /^\#127.0.0.1\\t"$this_site"/s//127.0.0.1\\t"$this_site"/ /etc/hosts
  #echo "Blocking $this_site"
}
function unblock_host() {
  this_site=$1
  sed -rin /^127.0.0.1\\t"$this_site"/s//\#127.0.0.1\\t"$this_site"/ /etc/hosts
  #echo "Unlocking $this_site"
}

if [[ $2 -le 0 ]]; then
  echo "seconds ($2) must be greater than 0"
  echo "$0 usage [block|unblock] #seconds"
  exit 1
fi

date
if [ "$1" == "block" ]; then
  echo "Blocking sites"
  for SITE in $SITES; do
    block_host "$SITE"
  done
  start_timer "$2"
  for SITE in $SITES; do
    unblock_host "$SITE"
  done
  date
elif [ "$1" == "unblock" ]; then
  echo "Unblocking sites"
  for SITE in $SITES; do
    unblock_host "$SITE"
  done
  start_timer "$2"
  for SITE in $SITES; do
    block_host "$SITE"
  done
  date
else
  echo "$0 requires argument [block|unblock]"
fi
