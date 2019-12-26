We are configuring a Cellery installation for you. This will take a few minutes to complete.

While it is configuring let's write a simple hello world cell YAML file from scratch.

1. First, create a new `hello-world.yaml`{{open}} file to write some code.

2. We need to define the `APIVersion` and the `Kind` which allows Kubernetes to understand Cell.
    <pre class="file" data-filename="hello-world.yaml" data-target="append">
   apiVersion: mesh.cellery.io/v1alpha2
   kind: Cell</pre>

3. Use `metadata` field for define name, namespace, labels and any other Kubernetes metadata

    <pre class="file" data-filename="hello-world.yaml" data-target="append">
   metadata:
     name: hello</pre>

4. Add the `spec` section which defines all the cell configurations.
    <pre class="file" data-filename="hello-world.yaml" data-target="append">
   spec:</pre>

5. Let's add a new Component configuration based on a hello world docker image. 
    <pre class="file" data-filename="hello-world.yaml" data-target="append">
     components:
         - metadata:
             name: hello  # define the component name
           spec:
             type: Deployment  # define the workload type
             scalingPolicy:
               replicas: 1     # here we use manual scaling set to 1 replica
             template:         # template is equivalent to Kubernetes PodTemplate
               containers:
                 - env:
                     - name: HELLO_NAME
                       value: Cellery
                   image: wso2cellery/samples-hello-world-webapp
                   name: hello
                   ports:
                     - containerPort: 80
                       protocol: TCP
             ports:     # expose our hello container on port 80
               - name: hello-80
                 port: 80
                 protocol: http
                 targetContainer: hello
                 targetPort: 80</pre>
       
6. Configure the cell gateway to expose our hello component.
    <pre class="file" data-filename="hello-world.yaml" data-target="append">
     gateway:
       spec:
         ingress:
           extensions:
             clusterIngress:
               host: [[HOST_SUBDOMAIN]]-8000-[[KATACODA_HOST]].environments.katacoda.com # this is the domain we expose our cell to outside
           http:
             - context: /       # here we specify the routes to our hello component via cell gateway
               destination:
                 host: hello
                 port: 80
               port: 80</pre>

**Congratulations! You just wrote your first cell YAML file.**

