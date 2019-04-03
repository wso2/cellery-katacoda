We will be modifying the HTML page and dockerizing the page in this step.
  
We have prepared a hello world sample and the required Dockerfile to containerize the Hello world.  
`cd /root/workspace/custom`{{execute}}

Open the hello world html by clicking the following link and edit it as you like.  
`custom/index.html`{{open}}  
`custom/Dockerfile`{{open}}

We will be needing a docker hub account to push the docker image.  
If you don’t have one, you can sign up using https://hub.docker.com/signup  
`docker login`{{execute}}

Execute below command to set the docker username as ORG system variable. By default the ORG_NAME system variable is set to ‘wso2-cellery’.

`export ORG_NAME=<DOCKER_USERNAME>`

You have to use the docker build to build your new image.  
Since we need to push the docker image afterward we will be tagging the image while building.  
`docker build --tag $ORG_NAME/hello-world .`{{execute}}

We will be pushing the docker image you just built using the following command.  
`docker push $ORG_NAME/hello-world`{{execute}}

Now, you have to replace the source field of the Cell file with your own docker image.

Rebuild and run the Cell file  
`sed -i 's/hello-world.com/[[HOST_SUBDOMAIN]]-2000-[[KATACODA_HOST]].environments.katacoda.com/g' hello-world.bal`{{execute}}

`cellery build hello-world.bal $ORG_NAME/hello-world:1.0.0`{{execute}}  
`cellery run $ORG_NAME/hello-world:1.0.0`{{execute}}

Once it's ready you can click Web Cell tab to open the hello world page.

After Cell is ready click on the web cell and visits the updated cell.
