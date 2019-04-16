wget https://github.com/wso2-cellery/sdk/releases/download/v0.2.0/cellery-ubuntu-x64-0.2.0.deb
sudo dpkg -i cellery-ubuntu-x64-0.2.0.deb

curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get -y install git
sudo apt-get -y install nodejs
#TODO DOCS VIEW

#WSO2Cellery Docker images
docker pull wso2cellery/hello-world-cell
docker pull wso2cellery/hello-world-api-cell
docker pull wso2cellery/sampleapp-stock
docker pull wso2cellery/sampleapp-salary
docker pull wso2cellery/sampleapp-employee
docker pull wso2cellery/samples-productreview-ratings
docker pull wso2cellery/sampleapp-hr
docker pull wso2cellery/samples-productreview-mysql
docker pull wso2cellery/samples-pet-store-portal
docker pull wso2cellery/samples-pet-store-customers
docker pull wso2cellery/samples-pet-store-orders
docker pull wso2cellery/samples-pet-store-catalog
docker pull wso2cellery/samples-pet-store-controller
docker pull wso2cellery/cell-gateway-base
docker pull wso2cellery/wso2is-lightweight
docker pull wso2cellery/sp-worker-base
docker pull wso2cellery/cell-gateway
docker pull wso2cellery/cell-gateway-init
docker pull wso2cellery/wso2am
docker pull wso2cellery/envoy-oidc-filter
docker pull wso2cellery/mesh-controller
docker pull wso2cellery/cell-sts
docker pull wso2cellery/sp-worker
docker pull wso2cellery/observability-portal
docker pull wso2cellery/samples-productreview-products
docker pull wso2cellery/samples-productreview-customers

#Istio Docker images
docker pull gcr.io/istio-release/proxy_init:1.0.2
docker pull quay.io/coreos/hyperkube:v1.7.6_coreos.0
docker pull docker.io/prom/statsd-exporter:v0.6.0
docker pull gcr.io/istio-release/galley:1.0.2
docker pull gcr.io/istio-release/proxyv2:1.0.2
docker pull gcr.io/istio-release/grafana:1.0.2
docker pull gcr.io/istio-release/mixer:1.0.2
docker pull gcr.io/istio-release/pilot:1.0.2
docker pull docker.io/prom/prometheus:v2.3.1
docker pull gcr.io/istio-release/citadel:1.0.2
docker pull gcr.io/istio-release/servicegraph:1.0.2
docker pull gcr.io/istio-release/sidecar_injector:1.0.2
docker pull docker.io/jaegertracing/all-in-one:1.5

#Test Run
download_path=${DOWNLOAD_PATH:-tmp-cellery}
distribution_url=${GIT_DISTRIBUTION_URL:-https://github.com/wso2-cellery/distribution/archive}
observability_url=${GIT_OBSERVABILITY_URL:-https://github.com/wso2-cellery/mesh-observability/archive}
release_version=${RELEASE_VERSION:-master}

mkdir ${download_path}
wget ${distribution_url}/${release_version}.zip -O ${download_path}/${release_version}.zip -a cellery-setup.log
unzip ${download_path}/${release_version}.zip -d ${download_path}
wget ${observability_url}/${release_version}.zip -O ${download_path}/${release_version}.zip -a cellery-setup.log
unzip ${download_path}/${release_version}.zip -d ${download_path}

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


#Deploy Cellery k8s artifacts
#Create Cellery ns
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/ns-init.yaml

HOST_NAME=$(hostname | tr '[:upper:]' '[:lower:]')
#label the node if k8s provider is kubeadm
kubectl label nodes $HOST_NAME disk=local

#Create mysql deployment
kubectl create configmap mysql-dbscripts --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/dbscripts/ -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-persistent-volumes-local.yaml -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-persistent-volume-claim.yaml -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-deployment.yaml -n cellery-system
#Wait till the mysql deployment availability
kubectl wait deployment/wso2apim-with-analytics-mysql-deployment --for condition=available --timeout=6000s -n cellery-system
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/mysql/mysql-service.yaml -n cellery-system

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

kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/mandatory.yaml
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/system/service-nodeport.yaml

#Observability
#Create SP worker configmaps
kubectl create configmap sp-worker-siddhi --from-file=${download_path}/mesh-observability-${release_version}/components/global/core/io.cellery.observability.siddhi.apps/src/main/siddhi -n cellery-system
kubectl create configmap sp-worker-conf --from-file=${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/sp/conf -n cellery-system
#Create SP worker deployment
kubectl apply -f ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/sp/sp-worker.yaml -n cellery-system
#Create SP dashboard configmaps

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

cd ~/
sudo rm -r tmp-cellery
sudo rm cellery-setup.log
sudo rm cellery-ubuntu-x64-0.2.0.deb

