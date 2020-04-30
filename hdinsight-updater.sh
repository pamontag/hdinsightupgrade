#! /bin/bash
#set -ex

#This custom action script manage updates and reboots on HDInsight cluster

#Usage:
#This script needs those arguments. 

#Version 1.0

write_log() {
    echo "`date +%Y/%m/%d-%H:%M:%S`: $1" >> $LOGFILEDATE  
    echo "`date +%Y/%m/%d-%H:%M:%S`: $1"
}

get_configuration_value() {
    if [[ $1 == "updates" ]]
    then
    conf_value=$(echo $CONF | ./jq-linux64 --arg pattern "$2" '.configuration | .updates | .[$pattern]')   
    elif [[ $1 == "reboot" ]]
    then
    conf_value=$(echo $CONF | ./jq-linux64 --arg pattern "$2" '.configuration | .reboot | .[$pattern]') 
    fi
    echo $conf_value
}

get_node_schedule() {
    node_schedule=$(echo $CONF | ./jq-linux64 --arg NODE "$1" '.configuration.nodeschedules[] | select(.node == $NODE) | .schedule' )
    echo "$node_schedule"
}

LOGPATH="./logs/" #/tmp/
LOGFILE="hdinsightupdater.log"
LOGFILEDATE="$LOGPATH$(date +%Y%m%d%H%M%S)_$LOGFILE"

write_log "Executing HDInsight Updater script Version 1.0"

write_log "Read configuration file hdinsight-updater-config.json"
CONF=$(cat hdinsight-updater-config.json)


UPDATETYPE=$(get_configuration_value "updates" "updatetype")

write_log "Starting with update type $UPDATETYPE"


 


 

