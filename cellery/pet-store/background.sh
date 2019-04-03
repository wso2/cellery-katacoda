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

start=$(date +%s)
git clone https://github.com/wso2-cellery/samples
mv samples/pet-store /root

launch.sh

rm -r samples

git clone https://github.com/wso2-cellery/distribution.git
git clone https://github.com/wso2-cellery/mesh-observability

sudo apt-get remove -y cellery
wget https://github.com/xlight05/katacoda-scenarios/releases/download/0.0.2/cellery-ubuntu-x64-acc7aa3c8c5ff0ae86120bedf2c17812205510f5.deb
sudo dpkg -i cellery-ubuntu-x64-acc7aa3c8c5ff0ae86120bedf2c17812205510f5.deb

sudo cp /usr/share/cellery/runtime/ballerina-0.990.3/bre/lib/cellery-0.2.0-SNAPSHOT.jar /usr/lib/ballerina/ballerina-0.990.3/bre/lib
sudo cp -r /usr/share/cellery/repo/celleryio /usr/lib/ballerina/ballerina-0.990.3/lib/repo
mkdir -p ~/.ballerina/repo/
sudo cp -r /usr/share/cellery/repo/celleryio /usr/lib/ballerina/ballerina-0.990.3/lib/repo ~/.ballerina/repo/

sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/global-idp/conf/carbon.xml
sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/global-idp/global-idp.yaml

#cellery-dashboard
sed -i 's/cellery-dashboard/[[HOST_SUBDOMAIN]]-4000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/observability/portal/observability-portal.yaml
#TODO portal.json

#cellery-k8s-metrics
sed -i 's/cellery-k8s-metrics/[[HOST_SUBDOMAIN]]-5000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/observability/grafana/config/grafana.ini
sed -i 's/cellery-k8s-metrics/[[HOST_SUBDOMAIN]]-5000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/observability/grafana/k8s-metrics-grafana.yaml
sed -i 's/cellery-k8s-metrics/[[HOST_SUBDOMAIN]]-5000-[[KATACODA_HOST]].environments.katacoda.com/g' mesh-observability/components/global/portal/io.cellery.observability.ui/node-server/config/portal.json

#wso2sp-observability-api
sed -i 's/wso2sp-observability-api/[[HOST_SUBDOMAIN]]-6000-[[KATACODA_HOST]].environments.katacoda.com/g' mesh-observability/components/global/portal/io.cellery.observability.ui/node-server/config/portal.json
sed -i 's/wso2sp-observability-api/[[HOST_SUBDOMAIN]]-6000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/observability/sp/sp-worker.yaml

wget https://gist.githubusercontent.com/xlight05/47f325fd883f97c9d92cb972930deafc/raw/786c2265e9db95c9833f03dd2c8e931d85d8b071/katacoda-minobs.sh
chmod +x katacoda-minobs.sh
./katacoda-minobs.sh
rm katacoda-minobs.sh

wget https://gist.githubusercontent.com/xlight05/3fa261aaef8d32dac4bc4b9d90f0dfd4/raw/89daca1a56721b29efaddece2b954b7c7b5de8be/service-nodeport.yaml
sed -i 's/172.17.17.100/[[HOST_IP]]/g' service-nodeport.yaml
kubectl apply -f service-nodeport.yaml
sudo rm service-nodeport.yaml
source <(kubectl completion bash)

wget https://raw.githubusercontent.com/wso2-cellery/mesh-controller/master/samples/pet-store-yamls/pet-backend.yaml
wget https://raw.githubusercontent.com/wso2-cellery/mesh-controller/af77d802c3bb4be87094db0ba98a7c8ea66de160/samples/pet-store-yamls/pet-frontend.yaml
sed -i 's/pet-store.com/[[HOST_SUBDOMAIN]]-2000-[[KATACODA_HOST]].environments.katacoda.com/g' pet-frontend.yaml;
sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' pet-frontend.yaml;

kube-wait.sh

rm cellery-setup.log
rm -r distribution
rm -r mesh-observability
rm -r tmp-cellery
rm cellery-ubuntu-x64-acc7aa3c8c5ff0ae86120bedf2c17812205510f5.deb

echo "done" >> /root/katacoda-finished
end=$(date +%s)
echo "Took $(($end-$start)) seconds "