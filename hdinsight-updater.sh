#! /bin/bash
#set -ex

#This custom action script manage updates and reboots on HDInsight cluster

#Usage:
#This script needs those arguments. 

#Version 1.0

#COMMON FUNCTIONS

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

#INIT

LOGPATH="./logs/" #/tmp/
LOGFILE="hdinsightupdater.log"
LOGFILEDATE="$LOGPATH$(date +%Y%m%d%H%M%S)_$LOGFILE"

write_log "Executing HDInsight Updater script Version 1.0"
current_time_in_HH_MM=$(date +"%H:%M")
hostname=$(/bin/hostname -f)
host_instance=$(sed 's/[^0-9]*\([0-9]*\).*/\1/' <<< $hostname)

write_log "Current time in HH:MM is $current_time_in_HH_MM."
write_log "Current hostname is $hostname."
write_log "Current host instance is $host_instance"


# PREREQUISITES

write_log "Starting evaluating prerequisites..."

write_log "Read configuration file hdinsight-updater-config.json"
if [ ! -s "hdinsight-updater-config.json" ] 
then
    write_log "Configuration file hdinsight-updater-config.json not found. Exiting..."
    exit 1
fi
CONF=$(cat hdinsight-updater-config.json)

write_log "Verify presence of jq utility for reading JSON configuration"
if [ ! -s "jq-linux64" ] 
then
    write_log "Downloading jq-linux64 1.6 64 Bit binaries from https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64..."
    wget -O jq-linux64 -nv https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
    if [ ! -s "jq-linux64" ] 
    then
        write_log "Impossible to download jq-linux64 binaries. Exiting..."
        exit 1
    fi
    chmod 750 jq-linux64
fi

#EVALUATE CONFIGURATION

UPDATETYPE=$(get_configuration_value "updates" "updatetype")
RESTART=$(get_configuration_value "reboot" "restart")
LISTONLY=$(get_configuration_value "updates" "listonly")
nodeschedule=$(get_node_schedule $host_instance)
renum="^[01]?$"
re="^.*(kernel|security|all).*$"
if [[ ! $UPDATETYPE =~ $re ]] 
then
    write_log "Uncorrect update type select in configuration ($UPDATETYPE). Must be (kernel|security|all)"
    exit 1
fi
if [[ ! $RESTART =~ $renum ]] || [[ ! $LISTONLY =~ $renum ]]
then
    write_log "Uncorrect configuration values for restart or listonly. Must be 0 or 1 in configuration"
    exit 1
fi
if [[ -z $nodeschedule ]]
then
    nodeschedule=$(get_node_schedule $hostname)
    if [[ -z $nodeschedule ]]
    then
        write_log "Not found update schedule for $hostname"
        exit 1
    fi
fi
write_log "Configuration check PASSED"
write_log "Starting patching operation with patch type $UPDATETYPE"
write_log "Only list updates: $LISTONLY"
write_log "Required restart: $RESTART"
write_log "Node $hostname scheduled for operation at $nodeschedule"
 


 

