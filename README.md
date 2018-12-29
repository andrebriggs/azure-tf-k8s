# Setting up AKS (Azure k8s) via Terraform
The instructions assume you have Azure CLI and Terraform. In Azure CLI make sure your you have "set" a subscription.

## Create an Azure service principal
```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$AZURE_SUBSCRIPTION_ID"
```
Save the output results somewhere.

## Create an Azure resource group
```
az group create -l $RESOURCE_GROUP_LOCATION -n $RESOURCE_GROUP_NAME
```

## Create Storage account 
Navigate to the k8s directory ```cd k8s```

Run the shell script [setup-az-storage.sh](k8s/setup-az-storage.sh). Replace variables with your own. This file defines an Azure Blob container to store the terraform state.

## Getting started with what's inside the repo
### [variables.tf](k8s/variables.tf)
Adjust the values for each key in [variables.tf](k8s/variables.tf) to your liking. 

Please make sure the value fo the ssh_public_key exists. If not please create it by navigating to your ```~/.ssh``` directory and running ```ssh-keygen -o```

### [k8s.tf](k8s/k8s.tf)
This file defines the environment landscape you want to declaratively describe. The default file creates a resource group, log analytics, and an AKS cluster. Edit this file to your liking.

### [output.tf](k8s/output.tf)
This file describes the output variables you will see when Terraform applies a [plan](https://www.terraform.io/docs/configuration/outputs.html).


## Set service principal info for Terraform
Run the shell script (set-sp-variables.sh)[k8s/set-sp-variables.sh] and replace or set the environment variables with teh output from creating the Azure Service Principal

## How deploy with Terraform

Typical Terraform commands are _init_, _plan_, then _apply_

Run:

```
terraform init -backend-config="storage_account_name=$STORAGE_NAME" -backend-config="container_name=tfstate" -backend-config="access_key=$STORAGE_KEY" -backend-config="key=codelab.microsoft.tfstate"
```

Then run:

```
terraform plan -out out.plan
```

If no errors then run. This may take several minutes to run
```
terraform apply out.plan
```

Finally once a successful install has happened run kubbectl to verify the nodes are running. To configure kubctl first run

```
echo "$(terraform output kube_config)" > ./azurek8s
```
then 
```
export KUBECONFIG=./azurek8s
```
Run the following to verify 
```
kubectl get nodes
```
# How to tear down 
Run ```az group delete --name $RESOURCE_GROUP_NAME```