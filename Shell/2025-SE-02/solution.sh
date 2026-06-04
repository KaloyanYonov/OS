#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <start|stop|running|cleanup> [service]"
    exit 1
fi

if [ -z "$SVC_DIR" ]; then
    echo "SVC_DIR environment variable is not set"
    exit 2
fi

if [ ! -d "$SVC_DIR" ]; then
    echo "$SVC_DIR must be a directory"
    exit 3
fi

userComm="$1"

if [ "$userComm" = "start" ] || [ "$userComm" = "stop" ]; then
    if [ $# -ne 2 ]; then
        echo "Usage: $0 <start|stop> <service>"
        exit 4
    fi
fi

find_service_file() {
    local svcname="$1"
    while IFS= read -r file; do
        name=$(grep "^name:" "$file" | cut -d':' -f2 | xargs)
        if [ "$name" = "$svcname" ]; then
            echo "$file"
            return
        fi
    done < <(find "$SVC_DIR" -type f)
}

if [ "$userComm" = "start" ]; then
    svcfile=$(find_service_file "$2")
    if [ -z "$svcfile" ]; then
        echo "Service '$2' not found"
        exit 5
    fi

    name=$(grep "^name:"    "$svcfile" | cut -d':' -f2 | xargs)
    pidfile=$(grep "^pidfile:" "$svcfile" | cut -d':' -f2 | xargs)
    outfile=$(grep "^outfile:" "$svcfile" | cut -d':' -f2 | xargs)
    comm=$(grep "^comm:"   "$svcfile" | cut -d':' -f2-)

    if [ -f "$pidfile" ]; then
        pid=$(cat "$pidfile")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Service '$name' is already running (PID $pid)"
            exit 0
        fi
    fi

    bash -c "$comm" >> "$outfile" 2>&1 &
    pid="$!"
    echo "$pid" > "$pidfile"
    echo "Started '$name' with PID $pid"

elif [ "$userComm" = "stop" ]; then
    svcfile=$(find_service_file "$2")
    if [ -z "$svcfile" ]; then
        echo "Service '$2' not found"
        exit 5
    fi

    name=$(grep "^name:"    "$svcfile" | cut -d':' -f2 | xargs)
    pidfile=$(grep "^pidfile:" "$svcfile" | cut -d':' -f2 | xargs)

    if [ ! -f "$pidfile" ]; then
        echo "Service '$name' is not running (no pidfile)"
        exit 0
    fi

    pid=$(cat "$pidfile")
    if kill -15 "$pid" 2>/dev/null; then
        echo "Stopped '$name' (PID $pid)"
    else
        echo "Process $pid not found"
    fi

elif [ "$userComm" = "running" ]; then
    while IFS= read -r file; do
        name=$(grep "^name:"    "$file" | cut -d':' -f2 | xargs)
        pidfile=$(grep "^pidfile:" "$file" | cut -d':' -f2 | xargs)

        if [ -f "$pidfile" ]; then
            pid=$(cat "$pidfile")
            if kill -0 "$pid" 2>/dev/null; then
                echo "$name"
            fi
        fi
    done < <(find "$SVC_DIR" -type f) | sort

elif [ "$userComm" = "cleanup" ]; then
    while IFS= read -r file; do
        name=$(grep "^name:"    "$file" | cut -d':' -f2 | xargs)
        pidfile=$(grep "^pidfile:" "$file" | cut -d':' -f2 | xargs)

        if [ -f "$pidfile" ]; then
            pid=$(cat "$pidfile")
            if ! kill -0 "$pid" 2>/dev/null; then
                rm "$pidfile"
                echo "Removed pidfile for '$name'"
            fi
        fi
    done < <(find "$SVC_DIR" -type f)

else
    echo "Unknown command: $userComm"
    echo "Usage: $0 <start|stop|running|cleanup> [service]"
    exit 6
fi
