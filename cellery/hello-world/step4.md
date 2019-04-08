#### Cell
A cell is a collection of containers that work together. Cells can expose web sites or APIs (or both). Cells are independently deployable, manageable, and observable.

#### Component
A component is a microservice running in a container. In the future we also plan to add support serverless components.

In this scenario, Our goal is to deploy a simple hello world web app. Therefore we need only one component in the cell.

Notice the component definition: it specifies all the information about the component including the component’s name, container image, the network ingresses and any environment variables the component needs.

#### Build function
This method is executed when the cell is built (`cellery build`). This is coming up in the next step.

#### Run function
This method is executed when the cell is run (`cellery run`). This is coming up in the next step.

You can find more about the Cellery syntax by visiting https://github.com/wso2-cellery/spec
