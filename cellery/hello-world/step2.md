In order to demonstrate the outcome of the scenario, we will be using a pre built cell image which is hosted on cellery hub.

You can use the following command to run the prebuilt hello world web cell.  
`cellery run wso2cellery/hello-world-cell:0.3.0 -e VHOST_NAME=$VHOST_NAME -n hello -y`{{execute}}

As you can see in the terminal , above command checks your existing local cell images and if the requested image is not available in your local repository, it will perform a pull from the cellery registry to check if its available in cellery hub.

You can use the **Web Cell** button above the terminal to access the Web Cell.

You can use the **Docs View** button above the terminal to view the cell image.

We will be creating the Cell image for that simple hello world in next steps.  
`cellery terminate hello`{{execute}}
