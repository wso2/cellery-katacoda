#### Building the backend Cell  
Execute the following command to switch into backend folder  
`cd /root/pet-store/pet-be`{{execute}}

Build the pet-be Cell. It will generate the artifacts that are required to deploy your Cell  
`cellery build pet-be.bal wso2cellery/pet-be-cell:0.6.0`{{execute}}  

#### Building the frontend Cell
Execute the following command to switch into frontend folder  
`cd /root/pet-store/pet-fe`{{execute}}

Build the pet-fe Cell. It will generate the artifacts that are required to deploy your Cell  
`cellery build pet-fe.bal wso2cellery/pet-fe-cell:0.6.0`{{execute}}

#### Running the Petstore Sample

Run the pet-fe Cell. It will deploy the artifacts that are generated from the build command in kubernetes.  
`cellery run wso2cellery/pet-fe-cell:0.6.0 -e VHOST_NAME=$VHOST_NAME -n pet-fe -l petStoreBackend:pet-be -d`{{execute}}

You can view the status of Pet store frontend Cell deployment by running  
`cellery status pet-fe`{{execute}}

You can view the auto generated cell diagram by clicking **Docs View** in the terminal tab panel.
