#### Cell
A cell is a collection of components, grouped from design and implementation into deployment. A cell is independently deployable, manageable, and observable.

#### Component
A component represents business logic running in a container, serverless environment, or an existing runtime.

In this scenario, Our goal is to deploy a simple hello world web app. Therefore we need only one component in the cell.

Notice the component Object, it specifies all the information about the component including Component name, Docker image source, ingresses etc.

#### Build function
This method will be executed when you use `cellery build` in the next step. We will explain more about this in the next step.

#### Run function
This method will be executed when you use `cellery run` in the next step. We will explain more about this in the next step.

You can find more about the Cellery syntax by visiting https://github.com/wso2-cellery/spec
