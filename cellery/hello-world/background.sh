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

launch.sh

git clone https://github.com/wso2-cellery/distribution.git

sudo apt-get remove -y cellery
wget https://wso2.org/jenkins/job/cellery/job/sdk/124/artifact/installers/ubuntu-x64/target/cellery-ubuntu-x64-40772520b7f999ce62136c2417e138dfef8d1fab.deb
sudo dpkg -i cellery-ubuntu-x64-40772520b7f999ce62136c2417e138dfef8d1fab.deb

sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/global-idp/conf/carbon.xml
sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' distribution/installer/k8s-artefacts/global-idp/global-idp.yaml


wget https://gist.githubusercontent.com/xlight05/53b7fa9e23dee876b62f7734ef33c4ee/raw/a0e42f47e1ad14ac1c4a5f2717f2d91c94abf477/katacoda-min.sh
chmod +x katacoda-min.sh
./katacoda-min.sh
rm katacoda-min.sh

wget https://gist.githubusercontent.com/xlight05/3fa261aaef8d32dac4bc4b9d90f0dfd4/raw/89daca1a56721b29efaddece2b954b7c7b5de8be/service-nodeport.yaml
sed -i 's/172.17.17.100/[[HOST_IP]]/g' service-nodeport.yaml
kubectl apply -f service-nodeport.yaml
sudo rm service-nodeport.yaml
source <(kubectl completion bash)

kube-wait.sh

rm cellery-setup.log
rm -r distribution
rm -r tmp-cellery
rm cellery-ubuntu-x64-40772520b7f999ce62136c2417e138dfef8d1fab.deb

curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get -y install nodejs

echo "done" >> /root/katacoda-finished

cd /root/docs-view
npm install
node app.js


end=$(date +%s)
echo "Took $(($end-$start)) seconds "