#### Running the backend Cell  
Execute the following command to switch into backend folder  
`cd /root/pet-store/backend`{{execute}}

Build the pet-be Cell. It will generate the required artifacts that are required to deploy your Cell  
`cellery build pet-be.bal my-org/pet-be:0.1.0`{{execute}}

Run the pet-be Cell. It will deploy the artifacts that are generated from the build command in kubernetes.  
`cellery run my-org/pet-be:0.1.0 -n pet-be-inst`{{execute}}

You can view the status of Pet store backend Cell deployment by running  
`cellery status pet-be-inst`{{execute}}

#### Running the Frontend Cell  samples/samples/
Execute the following command to switch into frontend folder  
`cd /root/pet-store/frontend`{{execute}}

Since katacoda is hosted online, You have to execute following command to access the cell via web UI  
`sed -i 's/pet-store.com/[[HOST_SUBDOMAIN]]-2000-[[KATACODA_HOST]].environments.katacoda.com/g' pet-fe.bal`{{execute}}

Build the pet-fe Cell. It will generate the required artifacts that are required to deploy your Cell  
`cellery build pet-fe.bal my-org/pet-fe:0.1.0`{{execute}}

Run the pet-fe Cell. It will deploy the artifacts that are generated from the build command in kubernetes.  
`cellery run my-org/pet-fe:0.1.0 -n pet-fe-inst -l pet-be:pet-be-inst`{{execute}}

You can view the status of Pet store frontend Cell deployment by running  
`cellery status pet-fe-inst`{{execute}}

Once it's ready you can click Web Cell tab to open the Frontend web cell in your browser.
