It's time to deploy your cell. 

Go to your cell YAML file location using below command

`cd /root/workspace/`{{execute}}

Deploy your cell by running following command.  
`kubectl apply -f hello-world.yaml`{{execute}}

Once you deploy the cell, you can check the status images by running `kubectl get cells`{{execute}}

Wait until the cell get ready. Once it's ready you can click **Hello Cell** tab to open the hello world page.

Run `kubectl delete -f hello-world.yaml`{{execute}} to delete the cell
