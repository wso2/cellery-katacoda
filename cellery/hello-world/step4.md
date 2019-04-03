It's time to build and run your cell file. 

Notice the vhost field in the hello world cell. It allows you to access your web cell in a virtual host.  
However, Since katacoda is hosted online, You have to execute following command to access the cell via web UI  
`sed -i 's/hello-world.com/[[HOST_SUBDOMAIN]]-2000-[[KATACODA_HOST]].environments.katacoda.com/g' hello-world.bal`{{execute}}

Build command executes the build function in your Cell file. The main purpose of this command is to generate the required component artifacts for kubernetes.  
`cellery build hello-world.bal wso2-cellery/hello-world-cell:1.0.0`{{execute}}

The run command executes the run function in your Cell file. The main purpose of this command is to deploy your cell file inside kubernetes.  
`cellery run wso2-cellery/hello-world-cell:1.0.0`{{execute}}

You can specify any kind of logic inside above functions.

We will be discussing advanced use cases in future scenarios.

You can use the below command to see the status of the deployment.  
`cellery list instances`{{execute}}

Once it's ready you can click Web Cell tab to open the hello world page.
