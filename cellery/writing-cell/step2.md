It's time to build and run your cell file. 

Go to your cell file location using below command

`cd /root/workspace/`{{execute}}

Build your cell image by running following command. This executes the build function in your cell file.  
`cellery build hello-world.bal myorg/hello-world-cell:latest`{{execute}}

Once you build the image, you can check the available images by running `cellery list images`{{execute}}

Now you can run the cell image using following command. This executes run function inside the cell.

`cellery run myorg/hello-world-cell:latest -e VHOST_NAME=$VHOST_NAME -n hello -y`{{execute}}

To check the running cell instance, run `cellery list instances`{{execute}}


Once it's ready you can click **Hello Cell** tab to open the hello world page.

To terminate the running cell instance, run `cellery terminate hello`{{execute}}
