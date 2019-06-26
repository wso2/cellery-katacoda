# Cellery learning on Katacoda
This repository contains the source code that is used to for scenarios on  https://katacoda.com/wso2/courses/cellery.


## Folder structure
```
katacoda scenarios
├── cellery - 
│   ├── hello-world
│   │   ├── assets
│   │   │   ├── service-nodeport.yaml - Ingress with all the ports that needs to be exposed
│   │   │   └── wait.sh - Holds user until background script's tasks are done
│   │   ├── background.sh - Runtime script - Will be running from background
│   │   ├── foreground.sh - Runtime script - Will be running in user's active terminal
│   │   ├── index.json
│   └── pet-store
│       ├── assets
│   │   │   ├── service-nodeport.yaml - Ingress with all the ports that needs to be exposed
│   │   │   └── wait.sh - Holds user until background script's tasks are done
│   │   ├── background.sh - Runtime script - Will be running from background
│   │   ├── foreground.sh - Runtime script - Will be running in user's active terminal
│       ├── index.json
├── cellery-pathway.json - Course structure
├── environments - Prebuilt enviroment scripts
│   └── wso2
│       └── build
│           └── 1_init.sh
└── README.md
```

## Contributions

First, you want to fork this repo and sign up at [Katacoda](https://katacoda.com/login) with your GitHub handle.
1. Fork this repo 
1. Sign up at [Katacoda](https://katacoda.com/login) with your GitHub.
1. Configure your fork with your katacoda account [Katacoda configure](https://www.katacoda.com/docs/configure-git)
1. Clone your fork and make changes to the scenario on your master branch,Push it to your github and try it out in 
your own katacoda account
1. When you're satisfied, send in a pull request to Cellery katacoda scenarios

### Katacoda Guides
Scenario Layouts - https://www.katacoda.com/docs/scenarios/layouts  
Scenario content styling - https://www.katacoda.com/docs/scenarios/markdown-syntax  
Index.json file - https://www.katacoda.com/docs/scenarios/index-json  
Scenario assets - https://www.katacoda.com/docs/scenarios/pre-init  

## Exposing services outside
You can expose any port in katacoda to outside using following syntax Exposing port 8500  
`https://[[HOST_SUBDOMAIN]]-8500-[[KATACODA_HOST]].environments.katacoda.com/`

## Exposing Kubernetes Services
If your services are exposed through node port you expose like you expose that port as you expose a normal service

If your services are exposed through Ingress, you need to edit your ingresses to be accessible from outside

1. Assign a free port to the service using service-nodeport.yaml
    ```
    - name: cellery-dashboard
      port: 4000
      targetPort: 80
      protocol: TCP
      ```
2. Find and replace the host in your service to the katacoda url in runtime (In background script)
`sed -i 's/cellery-dashboard/[[HOST_SUBDOMAIN]]-4000-[[KATACODA_HOST]].environments.katacoda.com/g' ${download_path}/distribution-${release_version}/installer/k8s-artefacts/observability/portal/observability-portal.yaml`

### Wait scripts 
Connection between background.sh and foreground.sh will be done by `echo` commands. You can view wait.sh for the code

## Environment script and Runtime scripts
Environment script contains the stuff that has to be burnt in to the base image. This is mainly used to speed up user
 scenario startup time.  
* Ballerina SDK  
* Cellery CLI  
* Runtime docker images  
* NodeJS  
* Sample cloning

Note - Currently, environment build scripts will not be automatically deployed to katacoda.

Runtime script contains the stuff that has to be ran once the user starts the scenario

* Deploying Kubernetes related artifacts  
* Kubernetes ingress expose replacements
* Wait script related commands