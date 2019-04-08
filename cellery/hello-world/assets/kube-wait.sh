#!/usr/bin/env bash

set -e

function __is_pod_ready() {
    [[ "$(kubectl get po "$1" -n cellery-system -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}')" == 'True' ]]
}

function __pods_ready() {
    local pod
    
    [[ "$#" == 0 ]] && return 0
    
    for pod in $pods; do
        __is_pod_ready "$pod" || return 1
    done
    
    return 0
}

function __wait-until-pods-ready() {
    interval=3
    local period interval i pods
    while :
    do
        pods="$(kubectl get po -n cellery-system -l deployment=idp -o 'jsonpath={.items[*].metadata.name}')"
        if __pods_ready $pods; then
            return 0
        fi
        sleep 3
    done
    return 1
}

__wait-until-pods-ready
# vim: ft=sh :
