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

launch.sh
git clone https://github.com/xlight05/distribution
cd distribution
git checkout katakoda
sed -i 's/wso2-apim/[[HOST_SUBDOMAIN]]-2000-[[KATACODA_HOST]].environments.katacoda.com/g' installer/k8s-artefacts/global-apim/conf/carbon.xml;
sed -i 's/WSO2UM_DB/WSO2CarbonDB/g' installer/k8s-artefacts/global-apim/conf/user-mgt.xml;
rm installer/k8s-artefacts/global-apim/conf/datasources/master-datasources.xml
wget https://raw.githubusercontent.com/xlight05/distribution/katakoda/installer/k8s-artefacts/global-apim/conf/datasources/master-datasources.xml
mv master-datasources.xml ~/distribution/installer/k8s-artefacts/global-apim/conf/datasources/


cd installer/scripts/cellery-runtime-deployer
cat katakoda-full.sh | bash -s -- kubeadm

#Cleanup
cd ~/
sudo rm -r distribution
cd tutorial

wget https://gist.githubusercontent.com/xlight05/3fa261aaef8d32dac4bc4b9d90f0dfd4/raw/89daca1a56721b29efaddece2b954b7c7b5de8be/service-nodeport.yaml
sed -i 's/172.17.17.100/[[HOST_IP]]/g' service-nodeport.yaml
wget https://gist.githubusercontent.com/xlight05/73f50180840c40d25f9c9c7865054090/raw/99ddfe2869d055b271da07e21fb6d7f6f964b646/ingress.yaml
sed -i 's/wso2-apim-gateway/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' ingress.yaml;
sed -i 's/wso2-apim/[[HOST_SUBDOMAIN]]-2000-[[KATACODA_HOST]].environments.katacoda.com/g' ingress.yaml;
kubectl apply -f service-nodeport.yaml
kubectl apply -f ingress.yaml -n cellery-system
sudo rm service-nodeport.yaml
sudo rm ingress.yaml

source <(kubectl completion bash)
echo "done" >> /root/katacoda-finished
