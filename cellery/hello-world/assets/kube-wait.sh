#!/usr/bin/env bash
# ------------------------------------------------------------------------
#
# Copyright 2019 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
#
# ------------------------------------------------------------------------

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
