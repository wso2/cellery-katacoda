In order to demonstrate the outcome of the scenario, we will be using a pre built cell image which is hosted on docker hub.

You can use the following command to run the prebuilt hello world web cell.  
`cellery run wso2cellery/hello-world-cell:0.2.0 -n hello`{{execute}}

As you can see in the terminal , above command checks your existing local cell images and if the requested image is not available in your local repository, it will perform a pull from the docker registry to check if its available in docker hub.

You can use the **Web Cell** button above the terminal to access the Web Cell.

You can use the **Docs View** button above the terminal to view the cell image.

We will be creating the Cell image for that simple hello world in next steps.  
`cellery terminate hello`{{execute}}
