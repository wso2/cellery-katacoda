#### Build the Todo Composite  
Execute the following command to switch into the todo service composite folder  
`cd /root/todo-service`{{execute}}

Build the todo-composite. It will generate the artifacts that are required to deploy todo composite  
`cellery build todo-composite.bal wso2cellery/todo-composite:0.6.0`{{execute}}  

You can view the pre-generated composite diagram by clicking **Docs View** in the terminal tab panel.

#### Deploy the Todo Composite  

Run following command to deploy the todo composite.  
`cellery run wso2cellery/todo-composite:0.6.0 -n todos`{{execute}}

You can view the status of by running  
`cellery status todos`{{execute}}

#### Test the Todo Composite  

Run following command to exec into running pod inside the cluster.  
`kubectl exec -it debug-tools -c debug-tools bash`{{execute}}

Run following command to get todo list 
`curl http://todos--todos-service:8080/todos`{{execute}}

Run following command to create a todo 
`curl -X POST http://todos--todos-service:8080/todos -d '{"title":"Coursework submission","content":"Submit the course work at 9:00p.m","done":false}'`{{execute}}

Run following command to check the newly added todo 
`curl http://todos--todos-service:8080/todos/3`{{execute}}

Run following command to update the newly added todo to done state
`curl -X PUT http://todos--todos-service:8080/todos/3 -d '{"title":"Submission","content":"Submit the course work at 9:00p.m","done":true}'`{{execute}}

Run following command to check whether the todo is updated 
`curl http://todos--todos-service:8080/todos/3`{{execute}}

Run `exit`{{execute}} to exit from the pod

    