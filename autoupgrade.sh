#! /bin/bash
#List of commands to be executed, in order:
declare -a SYNC=("emaint sync --allrepos"
                 "emerge --regen -q"
                 "eix-update")
declare -a UPDATE=("emerge -uqv @system"
                   "emerge -uqv @world"
                   "emerge -uvqD @system"
                   "emerge -uvqD @world")
declare -a REBUILD=("emerge -uNUqv --with-bdeps=y @world"
                    "emerge -q @preserved-rebuild"
                    "emerge -aq --depclean"
                    "revdep-rebuild")
declare -a CHECK=("eclean-dist -d"
                  "eclean-pkg"
                  "eix-test-obsolete")

BASENAME="autoupgrade"
TAG="$BASENAME.sh"
STATUS_FILE="$BASENAME.status"
LOG_FILE="$BASENAME.log"

LOG_MESSAGE=""

MIN_TIME=43200 #min time interval between syncs in seconds
                  
writeLog(){ #Small log-writing utility
    local LOG_MESSAGE=$1
    local STAGE=$2
    echo "$LOG_MESSAGE: $STAGE" >> autoupgrade.log
}

statusUpdate(){
    TYPE=$1
    grep -v "$TYPE" "$STATUS_FILE" > "$STATUS_FILE.tmp"
    mv -f "$STATUS_FILE.tmp" "$STATUS_FILE"
    echo "$(date +%s) $TYPE" >> "$STATUS_FILE"
}

retry(){ #Reruns failed commands while changing their parameters
    LOG_MESSAGE="retry"
    local CMD=$1
    local ITERATION=$2
    
    local PROGRAM=${CMD%% *}
    local HEAD=${CMD% *}
    local TAIL=${CMD##* }
    local OPTION=""
    
    if [ $PROGRAM == "emerge" ]; then
        OPTION="--backtrack 100"
    else
        return;
    fi
    writeLog $LOG_MESSAGE "$HEAD $OPTION $TAIL"
    
    if [ $ITERATION -le 10 ]; then
        echo "$HEAD $OPTION $TAIL"
        $HEAD $OPTION $TAIL && LOG_MESSAGE="success" ||
        retry "$CMD" 11
    else
        LOG_MESSAGE="fail"
    fi
    writeLog $LOG_MESSAGE "$HEAD $OPTION $TAIL"
}

run(){
    RETRY=$1 #Arrays are passed by name
    NAME=$2[@] #Arrays galore!
    COMMANDS=("${!NAME}")
    local EXIT_CODE

    for i in "${COMMANDS[@]}"; do
        echo "$i"
        (sh -c "$i"; EXIT_CODE="$?") && LOG_MESSAGE="success" || LOG_MESSAGE="fail"
        
        if [ "$LOG_MESSAGE" == "fail" ] && [ "$RETRY" != "--no-retry" ]; then
            retry "$i" 1
        fi
        writeLog "$LOG_MESSAGE $i $EXIT_CODE"
    done
}

logger -t $TAG "Automatic update started"
echo "$(date +%s) started"

if [ -f "$LOG_FILE.old" ]; then
    rm "$LOG_FILE.old"
fi

if [ -f "$LOG_FILE" ]; then
    mv "$LOG_FILE" "$LOG_FILE.old"
fi
touch autoupgrade.log

if [ ! -f  "$STATUS_FILE" ]; then
    touch "$STATUS_FILE"
    echo "0 sync" > "$STATUS_FILE"
fi

SYNC_NEEDED='false'

SYNC_STRING=$(grep "sync" < "$STATUS_FILE")
LASTSYNC=${SYNC_STRING% *}
CURRENT_TIME="$(date +%s)"
if [ $((CURRENT_TIME-LASTSYNC)) -ge $MIN_TIME ]; then
    SYNC_NEEDED='true'
fi

if [ $SYNC_NEEDED = 'true' ]; then
    run --no-retry SYNC
    statusUpdate "sync"
fi
run --retry UPDATE
statusUpdate "update"
run --retry REBUILD
statusUpdate "rebuild"
run --no-retry CHECK
statusUpdate "check"

logger -t $TAG "Automatic update finished"
exit 0
