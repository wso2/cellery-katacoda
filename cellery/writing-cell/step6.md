It's time to build and run your cell file. 

The `cellery build` command executes the build function in your cell file, which builds a cell image. The cell image is a set of component artifacts for kubernetes.  
`cellery build hello-world.bal <DOCKER_USERNAME>/hello-world-cell:1.0.0`

This web application displays the output depending on the environment variable that is being passed to the container. In order to change the Hello world output, execute the following command.  
`export HELLO_NAME="<Your Name here>"`

The run command runs your cell. This loads all the components and then executes the run function in your cell file. The result is that your cell is deployed into Kubernetes.  
`cellery run <DOCKER_USERNAME>/hello-world-cell:1.0.0`

You can specify any kind of logic inside the build and run functions, for example configuring the cell using environment variables.

You can use the below command to see the status of the deployment  
`cellery list instances`{{execute}}

Once it's ready you can click Web Cell tab to open the hello world page.
