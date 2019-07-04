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

export APIM_HOST_NAME="[[HOST_SUBDOMAIN]]-9000-[[KATACODA_HOST]].environments.katacoda.com"
export APIM_GATEWAY_HOST_NAME="[[HOST_SUBDOMAIN]]-9002-[[KATACODA_HOST]].environments.katacoda.com"
export OBSERVABILITY_HOST_NAME="[[HOST_SUBDOMAIN]]-9004-[[KATACODA_HOST]].environments.katacoda.com"
export OBSERVABILITY_API_HOST_NAME="[[HOST_SUBDOMAIN]]-9006-[[KATACODA_HOST]].environments.katacoda.com"

export HOST_SUBDOMAIN="[[HOST_SUBDOMAIN]]"
export KATACODA_HOST="[[KATACODA_HOST]]"
export HOST_IP="[[HOST_IP]]"


ARTIFACTS_BASE_PATH=/usr/share/cellery/k8s-artefacts
TEMP_DIR=/tmp

clean_previous_installation(){
    sudo apt-get purge -y cellery ballerina-0.990.3
}

install_ballerina(){
    wget --directory-prefix=${TEMP_DIR} https://product-dist.ballerina.io/downloads/0.991.0/ballerina-linux-installer-x64-0.991.0.deb
    sudo dpkg -i ${TEMP_DIR}/ballerina-linux-installer-x64-0.991.0.deb
}

install_cellery(){
    wget --directory-prefix=${TEMP_DIR} https://github.com/wso2-cellery/sdk/releases/download/v0.3.0/cellery-ubuntu-x64-0.3.0.deb
    sudo dpkg -i ${TEMP_DIR}/cellery-ubuntu-x64-0.3.0.deb
}

update_apim_host_config () {
    echo 'Updating API Manager Host Configurations'
    find ${ARTIFACTS_BASE_PATH}/global-apim/ -type f -exec sed -i 's/idp.cellery-system/'${APIM_HOST_NAME}'/g' {} +
    find ${ARTIFACTS_BASE_PATH}/global-apim/ -type f -exec sed -i 's/wso2-apim-gateway/'${APIM_GATEWAY_HOST_NAME}'/g' {} +
    find ${ARTIFACTS_BASE_PATH}/global-apim/ -type f -exec sed -i 's/wso2-apim/'${APIM_HOST_NAME}'/g' {} +
}

update_observability_host_config () {
    echo 'Updating Observability Host Configurations'
    find ${ARTIFACTS_BASE_PATH}/observability/ -type f -exec sed -i 's/cellery-dashboard/'${OBSERVABILITY_HOST_NAME}'/g' {} +
    find ${ARTIFACTS_BASE_PATH}/observability/ -type f -exec sed -i 's/idp.cellery-system/'${APIM_HOST_NAME}'/g' {} +
    sed -i 's/http:\/\/wso2sp-observability-api/https:\/\/'${OBSERVABILITY_API_HOST_NAME}'/g' ${ARTIFACTS_BASE_PATH}/observability/node-server/config/portal.json
    sed -i 's/wso2sp-observability-api/'${OBSERVABILITY_API_HOST_NAME}'/g' ${ARTIFACTS_BASE_PATH}/observability/sp/sp-worker.yaml
}

update_host_ip() {
    echo 'Updating Host IP'
    cp ${TEMP_DIR}/service-nodeport.yaml ${ARTIFACTS_BASE_PATH}/system/service-nodeport.yaml
    sed -i 's/xxx.xxx.xxx.xxx/'${HOST_IP}'/g' ${ARTIFACTS_BASE_PATH}/system/service-nodeport.yaml
}


clean_previous_installation

install_ballerina
echo "done" >> /opt/.ballerinaInstalled

install_cellery
echo "done" >> /opt/.celleryInstalled


update_apim_host_config
update_observability_host_config
update_host_ip
echo "done" >> /opt/.artifactsUpdated
