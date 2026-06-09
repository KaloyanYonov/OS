#!/bin/bash


if ! echo "$@" | grep -qw "\-jar"; then
    echo "Error: -jar option is required"
    exit 1
fi

java_opts=""
jar_file=""
main_args=""
after_jar=false

for arg in "$@"; do
    if [ "$arg" == "-jar" ]; then
        after_jar=true
        continue
    fi

    if [[ "$after_jar" == true ]] && [ -z "$jar_file" ]; then
        if echo "$arg" | grep -qE '^-D'; then
            java_opts="$java_opts $arg"
        else
            jar_file="$arg"
        fi
    elif [[ "$after_jar" == true ]] && [ -n "$jar_file" ]; then
        main_args="$main_args $arg"
    else
        java_opts="$java_opts $arg"
    fi
done

if [ -z "$jar_file" ]; then
    echo "Error: no JAR file specified"
    exit 2
fi

eval "java $java_opts -jar $jar_file $main_args"
