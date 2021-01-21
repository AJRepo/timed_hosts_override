#!/bin/bash
#Possible Overrides: 
# * Use NetworkManager.conf set dns=dnsmasq and define addn-hosts in dnsmasq.d/...
# * Edit /etc/hosts
# * Use ncsd and LD_PRELOAD or LD_LIBRARY_PATH

#This script overwrites /etc/hosts with an overrides file

#Uses the program "countdowntimer" https://github.com/AJRepo/countdowntimer


#Backup file to be created
BACKUP_FILE="/etc/hosts.bak"
#Overrides file to be used
OVERRIDE_FILE="/etc/hosts.overrides"

#if [[ $EUID -ne 0 ]]; then
if [ ! -w /etc/hosts ]; then
   echo "You do not have write access to /etc/hosts. Recommend calling this script with sudo to avoid sudo timeout." 1>&2
   exit 1
fi

if [[ $SUDO_USER != "" ]]; then
  WHOAMI=$SUDO_USER
else
  WHOAMI=$(whoami)
fi

MYGROUP=$(groups "$WHOAMI" | awk '{print $1}')

if [ -e "$BACKUP_FILE" ]; then
  diff -q /etc/hosts $BACKUP_FILE
  if [ $? == 1 ]; then
    echo "Stopping - backup file $BACKUP_FILE exists and is different"
    exit
  fi
fi

sudo cp /etc/hosts $BACKUP_FILE

if [ ! -e "$OVERRIDE_FILE" ]; then
    echo "Stopping - $OVERRIDE_FILE does not exist."
    exit
fi 

sudo cp $OVERRIDE_FILE /etc/hosts
if [ $? == 1 ]; then
  echo "Stopping - Error in copying over $OVERRIDE_FILE"
  exit
fi

countdowntimer.py --minutes 20 --quiet --terminal_beep

echo -e '\a'

#Check if command play exists and if so make a sound
if [[ $(command -v wall) ]]; then
  wall "$MYGROUP" "Time's Up"
fi
#if [[ $(command -v play) ]]I; then
#  play -nq -t alsa synth .5 sine 440
#fi

#Restore from backup
sudo mv $BACKUP_FILE /etc/hosts

if [ $? == 1 ]; then
  wall "$MYGROUP" "Warning - Error in restoring over $BACKUP_FILE"
fi
