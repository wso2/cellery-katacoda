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

wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u202-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u202b08.tar.gz
mkdir /usr/java
sudo tar xvzf OpenJDK8U-jdk_x64_linux_hotspot_8u202b08.tar.gz -C /usr/java
rm OpenJDK8U-jdk_x64_linux_hotspot_8u202b08.tar.gz

sudo apt-get remove -y cellery
wget https://wso2.org/jenkins/job/cellery/job/sdk/103/artifact/installers/ubuntu-x64/target/cellery-ubuntu-x64-730f882deb03fa8e0a58151d8134c8988987e4f2.deb
sudo dpkg -i cellery-ubuntu-x64-730f882deb03fa8e0a58151d8134c8988987e4f2.deb

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
rm cellery-ubuntu-x64-730f882deb03fa8e0a58151d8134c8988987e4f2.deb

echo "done" >> /root/katacoda-finished
end=$(date +%s)
echo "Took $(($end-$start)) seconds "