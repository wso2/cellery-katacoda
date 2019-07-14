We are configuring a Cellery installation for you. This will take a few minutes to complete.

While it is configuring let's write a simple hello world cell file from scratch.


1. First, create a new `hello-world.bal`{{open}} file to write some code.

2. We need to import `celleryio/cellery` package which contains the SDK for writing cells. The `ballerina/config` is used for reading configurations from the environment variables.
    <pre class="file" data-filename="hello-world.bal" data-target="append">
   import ballerina/config;
   import celleryio/cellery;
   </pre>

3. The `build` function is the most important function which you build up your cell using SDK. This function is executed when you issue a `cellery build` command to build a reusable cell image.

    <pre class="file" data-filename="hello-world.bal" data-target="append">
   public function build(cellery:ImageName iName) returns error? {
   </pre>

4. Let's create a new Component which based on a hello world docker image.
    <pre class="file" data-filename="hello-world.bal" data-target="append">
       cellery:Component helloComponent = {</pre>

5. Give it a name. Naming your component is always a good idea.
    <pre class="file" data-filename="hello-world.bal" data-target="append">
           name: "hello",</pre>

6. Specify the docker image in the source section.
    <pre class="file" data-filename="hello-world.bal" data-target="append">
           source: {
               image: "wso2cellery/samples-hello-world-webapp"
           },</pre>

7. The `ingress` section is the place where you declare how your component get exposed from the cell. As our hello world application
is producing html web page, we are going to expose it as a `WebIngress`. The `WebIngress` will expose your cell outside from the Kubernetes cluster with hostname specified in `vhost` section. 
    <pre class="file" data-filename="hello-world.bal" data-target="append">
           ingresses: {
               webUI: &lt;cellery:WebIngress&gt;{
                   port: 80,
                   gatewayConfig: {
                       vhost: "hello-world.com",
                       context: "/"
                   }
               }
           },</pre>

8. This is where you defined the environment variables for your component. Here, we are giving `Cellery` to `HELLO_NAME` variable which is used when producing hello world message. 
    <pre class="file" data-filename="hello-world.bal" data-target="append">
           envVars: {
               HELLO_NAME: { value: "Cellery" }
           }</pre>   

9. Make sure to close the curly brackets for the Component 
    <pre class="file" data-filename="hello-world.bal" data-target="append">
       };
   </pre>

10. Now you can define a `CellImage` and attach the components
    <pre class="file" data-filename="hello-world.bal" data-target="append">
        cellery:CellImage helloCell = {
            components: {
                helloComp: helloComponent
            }
        };
    </pre>

11. Call the `cellery:createImage` to build the actual cell image.

    <pre class="file" data-filename="hello-world.bal" data-target="append">
       return cellery:createImage(helloCell, untaint iName);</pre>

12. Close the curly brackets for the `build` function
    <pre class="file" data-filename="hello-world.bal" data-target="append">
    }
    </pre>

13. The `run` function is executed when you issue a `cellery run` command to deploy a cell.
    <pre class="file" data-filename="hello-world.bal" data-target="append">
    public function run(cellery:ImageName iName, map&lt;cellery:ImageName&gt; instances) returns error? {
    </pre>

14. We can use `cellery:constructCellImage` to generate our original cell image and do various modification before running the cell. 
    <pre class="file" data-filename="hello-world.bal" data-target="append">
        cellery:CellImage helloCell = check cellery:constructCellImage(untaint iName);</pre>

15. We are planing to read the hostname from `VHOST_NAME` environment variable
    <pre class="file" data-filename="hello-world.bal" data-target="append">
        string vhostName = config:getAsString("VHOST_NAME");
        if (vhostName !== "") {
            cellery:WebIngress web = &lt;cellery:WebIngress&gt;helloCell.components.helloComp.ingresses.webUI;
            web.gatewayConfig.vhost = vhostName;
        }
    </pre>

16. Here, we are setting a custom hello message if user specified via environment variable

    <pre class="file" data-filename="hello-world.bal" data-target="append">
        string helloName = config:getAsString("HELLO_NAME");
        if (helloName !== "") {
            helloCell.components.helloComp.envVars.HELLO_NAME.value = helloName;
        }
    </pre>

17. Finally, we are creating the actual deployable cell instance by calling `cellery:createInstance` function.
    <pre class="file" data-filename="hello-world.bal" data-target="append">
        return cellery:createInstance(helloCell, iName, instances);</pre>
        
18. Close the curly brackets for the `run` function
    <pre class="file" data-filename="hello-world.bal" data-target="append">
    }
    </pre>



**Congratulations! You just wrote your first cell file.**

