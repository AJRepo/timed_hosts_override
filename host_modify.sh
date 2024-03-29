#!/bin/bash

#set -x

SITES="old.reddit.com www.reddit.com www.imgur.com imgur.com www.youtube.com youtube.com www.theguardian.com theguardian.com"
SITES="old.reddit.com www.reddit.com www.imgur.com imgur.com www.theguardian.com theguardian.com"
USE_PIETIMER="False"

#does pietimer exist? Searches system $PATH
#PIETIMER=$(which countdowntimer.py)
PIETIMER=$(which pietimer.py)
if readlink -q $PIETIMER > /dev/null ; then
  PIETIMER=$(readlink $PIETIMER)
fi
if [ -x "$PIETIMER" ]; then
  USE_PIETIMER="True"
else
  echo "------------------------------------------------------------------"
  echo "Can't find executable '$PIETIMER' so falling back on text only timer"
  echo "------------------------------------------------------------------"
fi


function start_timer() {
  local seconds=$1
  local color=$2
  if [[ "$color" == "" ]] ; then
    color="red"
  fi
  #echo "COLOR = $color"
  if [[ "$seconds" != "" ]] && [[ "$seconds" =~ ^[0-9]+$ ]] && [[ "$seconds" -gt 0 ]] ; then
    if [ $USE_PIETIMER == "True" ]; then
      if [[ $(whoami) == "root" ]]; then
        #No reason to run the timer as root
        if [[ $SUDO_USER != "" ]]; then
          echo "  For $seconds seconds: See gui timer"
          sudo -u "$SUDO_USER" "$PIETIMER" -- -d -q -s "$seconds" -c "$color"
        else
          echo "Won't run gui timer as root. Exiting."
          exit 1
        fi
        echo "In start_timer()"
      fi
    else
      echo "  For $seconds seconds"
      sleep "$seconds"
    fi
  fi
}


function block_host() {
  this_site=$1
  #echo "Blocking $this_site"
  if [ -w /etc/hosts ]; then
    sed -rin /^\#127.0.0.1\\t"$this_site"/s//127.0.0.1\\t"$this_site"/ /etc/hosts
  else
    echo "Don't have write access to /etc/hosts - exiting"
    exit 1
  fi
}

function block_hosts() {
  for SITE in $SITES; do
    block_host "$SITE"
  done
}

function unblock_host() {
  this_site=$1
  #echo "Unlocking $this_site"
  if [ -w /etc/hosts ]; then
    sed -rin /^127.0.0.1\\t"$this_site"/s//\#127.0.0.1\\t"$this_site"/ /etc/hosts
  else
    echo "Don't have write access to /etc/hosts - exiting"
    exit 1
  fi
}

function unblock_hosts() {
  for SITE in $SITES; do
    unblock_host "$SITE"
  done
}

if [[ $2 == "" ]]; then
  #echo "$0's 2nd argument, seconds ($2) is blank, making seconds=600 (10 min)"
  SECONDS=600
elif [[ $2 -le 0 ]]; then
  echo "seconds ($2) must be greater than 0"
  echo "$0 usage [block|unblock|pomodoro] #seconds"
  exit 1
else
  SECONDS="$2"
fi

if [[ "$3" == "" ]]; then
  #echo "$0's 3nd argument, color ($3) is blank, making color=red"
  COLOR="red"
else
  COLOR="$3"
fi

date
if [[ "$1" == "block" ]]; then
  echo "  Blocking sites"
  block_hosts
  #Start the timer
  start_timer "$SECONDS" "$COLOR"
  unblock_hosts
  date
elif [[ "$1" == "unblock" ]]; then
  echo "  Unblocking sites"
  unblock_hosts
  #Start the timer
  start_timer "$SECONDS" "$COLOR"
  block_hosts
  date
elif [[ "$1" == "pomodoro" || "$1" == "pmodoro" ]] ; then
  for SPRINT in $(seq 1 4); do
    echo "Sprint $SPRINT"
    SECONDS=1500
    COLOR="red"
    echo "  Blocking sites: Working"
    block_hosts
    start_timer "$SECONDS" "$COLOR"

    SECONDS=300
    COLOR="orange"
    echo "  Five Minute Break"
    unblock_hosts
    start_timer "$SECONDS" "$COLOR"
  done
  SECONDS=1800
  COLOR="green"
  echo "  Restorative Break"
  unblock_hosts
  start_timer "$SECONDS" "$COLOR"
  echo "Done!"
  echo "Blocking sites: Reset to default"
  block_hosts
else
  echo "$0 requires argument [block|unblock|pomodoro]"
fi
