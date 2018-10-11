#!/usr/bin/env bash

set -e
#set -x
shopt -s expand_aliases

# use goto, ref: https://stackoverflow.com/questions/9639103/is-there-a-goto-statement-in-bash#answer-45538151
alias goto="cat >/dev/null <<"

START_DIR=$(pwd)

cleanup() {
  if [[ $? -ne 0 && $? -ne 130 ]]; then
  cat <<EOF

  ______ _____  _____   ____  _____  
 |  ____|  __ \|  __ \ / __ \|  __ \ 
 | |__  | |__) | |__) | |  | | |__) |
 |  __| |  _  /|  _  /| |  | |  _  / 
 | |____| | \ \| | \ \| |__| | | \ \ 
 |______|_|  \_\_|  \_\\____/|_|  \_\

EOF
  fi
  cd $START_DIR
}

trap cleanup EXIT

#SETUP_INTERFACE

printf "Insert SDCARD into your Raspberry Pi and connect with USB cable to your PC.\n"
printf "Waiting for interface comming up.";
while [[ `/sbin/ifconfig | grep "aa:bb:cc:dd:ee:ff" | wc -l` -eq 0 ]]; do
  sleep 1
  printf "."
done 
printf "\n"
IF_NAME=`/sbin/ifconfig | grep "aa:bb:cc:dd:ee:ff" | cut -d' ' -f1`
printf "Hardware interface is named $IF_NAME, trying to rename it in connection manager as \"PI\".\n";

while [[ `nmcli --terse --fields NAME,DEVICE con show | grep $IF_NAME | wc -l` -eq 0 ]]; do
  sleep 1
  printf "."
done;
printf "\n"
CON_NAME=`nmcli --terse --fields NAME,DEVICE con show | grep $IF_NAME | cut -d: -f1`
printf "Renaming \"$CON_NAME\" to \"PI\"\n";
nmcli con modify "$CON_NAME" connection.id PI
printf "Modifying connection PI to \"shared to other computers\"\n"; 
nmcli con mod PI ipv4.method shared
printf "Finished. Now wait 60s and try ssh pi@raspberrypi.local, password \"raspberry\" \n";

