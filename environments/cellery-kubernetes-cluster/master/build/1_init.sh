#!/bin/bash

TEMP_DIR=/tmp

install_ballerina(){
    wget --directory-prefix=${TEMP_DIR} https://product-dist.ballerina.io/downloads/0.991.0/ballerina-linux-installer-x64-0.991.0.deb
    sudo dpkg -i ${TEMP_DIR}/ballerina-linux-installer-x64-0.991.0.deb
    sudo rm ${TEMP_DIR}/ballerina-linux-installer-x64-0.991.0.deb
}

install_cellery(){
    wget --directory-prefix=${TEMP_DIR} https://github.com/wso2-cellery/sdk/releases/download/v0.4.0/cellery-ubuntu-x64-0.4.0.deb
    sudo dpkg -i ${TEMP_DIR}/cellery-ubuntu-x64-0.4.0.deb
    sudo rm ${TEMP_DIR}/cellery-ubuntu-x64-0.4.0.deb
}


install_ballerina
install_cellery
