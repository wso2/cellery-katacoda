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
    while true; do
        sudo grep -i "start" /root/katacoda-finished &> /dev/null
        if [[ "$?" -ne 0 ]]; then
            echo -ne '#                          (0%)\r'
        else 
            sudo grep -i "kubernetes" /root/katacoda-finished &> /dev/null
            if [[ "$?" -ne 0 ]]; then
                echo -ne '#############             (66%)\r'
            else 
                sudo grep -i "idp" /root/katacoda-finished &> /dev/null
                if [[ "$?" -ne 0 ]]; then
                    echo -ne '#######################   (100%)\r'
                    echo -ne '\n'
                else 
                    break
                fi
            fi
        fi
    done
    printf "    \b\b\b\b"
    echo ""
    echo "Cellery environment is ready"
}




show_progress
