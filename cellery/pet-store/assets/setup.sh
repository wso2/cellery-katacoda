#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2019 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
#
# ------------------------------------------------------------------------

echo "Updating Cellery Configuration..."; while [ ! -f /opt/.artifactsUpdated ] ; do sleep 1; done;
echo "Cellery configuration updated"

echo "Waiting for Kubernetes to start..."; while [ ! -f /root/.kube/config ] ; do sleep 1; done;
echo "Kubernetes started"

cellery setup create existing --complete

kubectl delete pods -l app=wso2sp-worker -n cellery-system
kubectl delete pods -l app=observability-portal -n cellery-system
