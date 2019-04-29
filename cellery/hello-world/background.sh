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


echo "start" >> /root/katacoda-finished
launch.sh

sudo apt-get remove -y cellery
wget https://github.com/wso2-cellery/sdk/releases/download/v0.2.0/cellery-ubuntu-x64-0.2.0.deb
sudo dpkg -i cellery-ubuntu-x64-0.2.0.deb

download_path=${DOWNLOAD_PATH:-tmp-cellery}
distribution_url=${GIT_DISTRIBUTION_URL:-https://github.com/wso2-cellery/distribution/archive}
release_version=${RELEASE_VERSION:-master}

#Download k8s artifacts
mkdir ${download_path}
wget ${distribution_url}/${release_version}.zip -O ${download_path}/${release_version}.zip -a cellery-setup.log
unzip ${download_path}/${release_version}.zip -d ${download_path}

cp -rf /usr/tmp/is/. ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/

echo "kube" >> /root/katacoda-finished


sed -i 's/WSO2UserDS/WSO2CarbonDB/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/user-mgt.xml
sed -i 's/WSO2IdentityDS/WSO2CarbonDB/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/identity/identity.xml
sed -i 's/WSO2ConsentDS/WSO2CarbonDB/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/consent-mgt-config.xml

sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/carbon.xml
sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/global-idp.yaml

#Deploy Cellery k8s artifacts
#Create Cellery ns
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/ns-init.yaml

HOST_NAME=$(hostname | tr '[:upper:]' '[:lower:]')
#label the node if k8s provider is kubeadm
kubectl label nodes $HOST_NAME disk=local

#Create Istio deployment
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/istio-crds.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/istio-demo-cellery.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/istio-gateway.yaml
kubectl wait deployment/istio-pilot --for condition=available --timeout=6000s -n istio-system
#Enabling Istio injection
kubectl label namespace default istio-injection=enabled

#Create Cellery CRDs.
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/01-cluster-role.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/02-service-account.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/03-cluster-role-binding.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/04-crd-cell.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/05-crd-gateway.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/06-crd-token-service.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/07-crd-service.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/08-config.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/09-autoscale-policy.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/controller/10-controller.yaml

#Create the IDP config maps
kubectl create configmap identity-server-conf --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf -n cellery-system
kubectl create configmap identity-server-conf-datasources --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/datasources/ -n cellery-system
kubectl create configmap identity-server-conf-identity --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/identity -n cellery-system
kubectl create configmap identity-server-tomcat --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/tomcat -n cellery-system
#kubectl create configmap identity-server-security --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/security -n cellery-system

#Create IDP deployment and the service
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/global-idp.yaml -n cellery-system


#Create ingress-nginx deployment
sed -i 's/172.17.17.100/[[HOST_IP]]/g' /usr/local/bin/service-nodeport.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/mandatory.yaml
kubectl apply -f /usr/local/bin/service-nodeport.yaml

source <(kubectl completion bash)

kube-wait.sh

echo "done" >> /root/katacoda-finished

curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get -y install nodejs

cd /root/docs-view
npm install
nohup node app.js > output.log &

cd ~/

observability_url=${GIT_OBSERVABILITY_URL:-https://github.com/wso2-cellery/mesh-observability/archive}
release_version=${RELEASE_VERSION:-master}

wget ${observability_url}/${release_version}.zip -O ${download_path}/${release_version}.zip -a cellery-setup.log
unzip ${download_path}/${release_version}.zip -d ${download_path}

sed -i 's/idp.cellery-system/[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/mesh-observability-${release_version}/components/global/portal/io.cellery.observability.ui/node-server/config/portal.json

#cellery-dashboard
sed -i 's/cellery-dashboard/[[HOST_SUBDOMAIN]]-4000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/portal/observability-portal.yaml
sed -i 's/cellery-dashboard/[[HOST_SUBDOMAIN]]-4000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/sp/conf/deployment.yaml
sed -i 's/cellery-dashboard/[[HOST_SUBDOMAIN]]-4000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/mesh-observability-${release_version}/components/global/portal/io.cellery.observability.ui/node-server/config/portal.json

#cellery-k8s-metrics
sed -i 's/cellery-k8s-metrics/[[HOST_SUBDOMAIN]]-5000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/grafana/config/grafana.ini
sed -i 's/cellery-k8s-metrics/[[HOST_SUBDOMAIN]]-5000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/grafana/k8s-metrics-grafana.yaml
sed -i 's/cellery-k8s-metrics/[[HOST_SUBDOMAIN]]-5000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/mesh-observability-${release_version}/components/global/portal/io.cellery.observability.ui/node-server/config/portal.json


#wso2sp-observability-api
sed -i 's/http:\/\/wso2sp-observability-api/https:\/\/[[HOST_SUBDOMAIN]]-6000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/mesh-observability-${release_version}/components/global/portal/io.cellery.observability.ui/node-server/config/portal.json
sed -i 's/wso2sp-observability-api/[[HOST_SUBDOMAIN]]-6000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/sp/sp-worker.yaml


#Create folders required by the mysql PVC
if [ -d /mnt/mysql ]; then
    mv /mnt/mysql "/mnt/mysql.$(date +%s)"
fi
mkdir -p /mnt/mysql
#Change the folder ownership to mysql server user.
chown 999:999 /mnt/mysql

declare -A config_params
config_params["MYSQL_DATABASE_HOST"]="wso2apim-with-analytics-rdbms-service"
config_params["DATABASE_USERNAME"]="cellery"
db_passwd=$(cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 16; echo)
config_params["DATABASE_PASSWORD"]=$db_passwd

for param in "${!config_params[@]}"
do
    sed -i "s/$param/${config_params[$param]}/g" ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/sp/conf/deployment.yaml
    sed -i "s/$param/${config_params[$param]}/g" ${download_path}/distribution-${release_version}/installer/k8s-artefacts/global-idp/conf/datasources/master-datasources.xml
done

for param in "${!config_params[@]}"
do
    sed -i "s/$param/${config_params[$param]}/g" ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/dbscripts/init.sql
done

#Create mysql deployment
kubectl create configmap mysql-dbscripts --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/dbscripts/ -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-persistent-volumes-local.yaml -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-persistent-volume-claim.yaml -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-deployment.yaml -n cellery-system
#Wait till the mysql deployment availability
kubectl wait deployment/wso2apim-with-analytics-mysql-deployment --for condition=available --timeout=6000s -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-service.yaml -n cellery-system

sleep 10

#Observability  
#Create SP worker configmaps
kubectl create configmap sp-worker-siddhi --from-file=${download_path}/mesh-observability-${release_version}/components/global/core/io.cellery.observability.siddhi.apps/src/main/siddhi -n cellery-system
kubectl create configmap sp-worker-conf --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/sp/conf -n cellery-system
#Create SP worker deployment
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/sp/sp-worker.yaml -n cellery-system
#Create observability portal deployment, service and ingress.
kubectl create configmap observability-portal-config --from-file=${download_path}/mesh-observability-${release_version}/components/global/portal/io.cellery.observability.ui/node-server/config -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/portal/observability-portal.yaml -n cellery-system

# Create K8s Metrics Config-maps
kubectl create configmap k8s-metrics-prometheus-conf --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/prometheus/config -n cellery-system
kubectl create configmap k8s-metrics-grafana-conf --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/grafana/config -n cellery-system
kubectl create configmap k8s-metrics-grafana-datasources --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/grafana/datasources -n cellery-system
kubectl create configmap k8s-metrics-grafana-dashboards --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/grafana/dashboards -n cellery-system
kubectl create configmap k8s-metrics-grafana-dashboards-default --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/grafana/dashboards/default -n cellery-system

#Create K8s Metrics deployment, service and ingress.
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/prometheus/k8s-metrics-prometheus.yaml -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/grafana/k8s-metrics-grafana.yaml -n cellery-system

rm cellery-setup.log
rm -r tmp-cellery
rm cellery-ubuntu-x64-0.2.0.deb
