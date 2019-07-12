#!/bin/bash
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

show_progress()
{
    echo -n "Preparing the environment"
    local -r pid="${1}"
    local -r delay='0.75'
    local spinstr='\|/-'
    local temp
    while true; do
        if sudo grep -i "done" /root/katacoda-finished &> /dev/null
        then
            break
        else
            temp="${spinstr#?}"
            printf " [%c]  " "${spinstr}"
            spinstr=${temp}${spinstr%"${temp}"}
            sleep "${delay}"
            printf "\b\b\b\b\b\b"
        fi
    done
    printf "    \b\b\b\b"
    echo ""
    echo "Cellery environment is ready"
}
# show_progress()
# {
#     echo "Preparing the environment"
#     while true; do
#         if sudo grep -i "done" /root/katacoda-finished &> /dev/null
#         then
#             echo -ne '#######################   (100%)\r'
#             echo -ne '\n'
#             break
#         elif sudo grep -i "kube" /root/katacoda-finished &> /dev/null
#         then
#             echo -ne '#############             (66%)\r'
            
#         elif sudo grep -i "start" /root/katacoda-finished &> /dev/null
#         then
#             echo -ne '#                          (0%)\r'
            
#         fi
#     done
#     printf "    \b\b\b\b"
#     echo ""
#     echo "Cellery environment is ready"
# }

show_progress
