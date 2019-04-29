#### Building the backend Cell  
Execute the following command to switch into backend folder  
`cd /root/pet-store/pet-be`{{execute}}

Build the pet-be Cell. It will generate the required artifacts that are required to deploy your Cell  
`cellery build pet-be.bal wso2cellery/pet-be-cell:0.2.0`{{execute}}  

#### Building the frontend Cell
Execute the following command to switch into frontend folder  
`cd /root/pet-store/pet-fe`{{execute}}

Build the pet-fe Cell. It will generate the required artifacts that are required to deploy your Cell  
`cellery build pet-fe.bal wso2cellery/pet-fe-cell:0.2.0`{{execute}}

#### Running the Petstore Sample

Run the pet-fe Cell. It will deploy the artifacts that are generated from the build command in kubernetes.  
`cellery run wso2cellery/pet-fe-cell:0.2.0 -n pet-fe -l petStoreBackend:pet-be -d`{{execute}}

You can view the status of Pet store frontend Cell deployment by running  
`cellery status pet-fe`{{execute}}

Once it's ready you can click Web Cell tab to open the Frontend web cell in your browser.
