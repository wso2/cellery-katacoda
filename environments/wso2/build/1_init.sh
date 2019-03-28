echo "Installing ballerina"
wget https://product-dist.ballerina.io/downloads/0.990.3/ballerina-linux-installer-x64-0.990.3.deb
chmod +x ballerina-linux-installer-x64-0.990.3.deb
sudo dpkg -i ballerina-linux-installer-x64-0.990.3.deb

#Installing CLI
echo "Installing Cellery CLI"
wget https://github.com/xlight05/katacoda-scenarios/releases/download/0.0.2/cellery-ubuntu-x64-0.1.1.deb
sudo chmod +x cellery-ubuntu-x64-0.1.1.deb
sudo dpkg -i cellery-ubuntu-x64-0.1.1.deb
sudo chmod -R 777 ~/.ballerina

echo "Pulling Docker images"
docker pull celleryio/mesh-controller
docker pull celleryio/cell-gateway-init
docker pull celleryio/cell-gateway-base
docker pull celleryio/wso2am
docker pull celleryio/observability-portal
docker pull celleryio/sp-worker
docker pull celleryio/cell-sts
docker pull celleryio/cell-gateway-base

#v0.1.0
docker pull celleryio/mesh-controller:v0.1.0
docker pull celleryio/cell-gateway-init:v0.1.0
docker pull celleryio/cell-gateway-base:v0.1.0
docker pull celleryio/wso2am:v0.1.0
docker pull celleryio/observability-portal:v0.1.0
docker pull celleryio/sp-worker:v0.1.0
docker pull celleryio/cell-sts:v0.1.0
docker pull celleryio/cell-gateway-base:v0.1.0

#WSO2Cellery
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

sudo apt-get install git
#Installing YAMLS use this only if katacoda supports
echo "Installing Cellery runtime"
git clone https://github.com/xlight05/distribution
cd distribution/installer/scripts/cellery-runtime-deployer
git checkout katakoda
cat katakoda-full.sh | bash -s -- kubeadm

cd ~/
sudo rm -r distribution
sudo rm cellery-ubuntu-x64-0.1.1.deb
sudo rm ballerina-linux-installer-x64-0.990.3.deb

echo "export ORG_NAME=wso2-cellery" | sudo tee -a ~/.bashrc 
echo "export CELLERY_HOME=/usr/bin/cellery" | sudo tee -a ~/.bashrc 
