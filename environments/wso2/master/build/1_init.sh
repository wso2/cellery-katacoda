wget https://github.com/wso2-cellery/sdk/releases/download/v0.2.0/cellery-ubuntu-x64-0.2.0.deb
sudo dpkg -i cellery-ubuntu-x64-0.2.0.deb
sudo rm cellery-ubuntu-x64-0.2.0.deb

curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get -y install git
sudo apt-get -y install nodejs
