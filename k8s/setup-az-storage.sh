az storage account create --resource-group $RESOURCE_GROUP --name $STORAGE_NAME --sku Standard_LRS

STORAGE_KEY=$(az storage account keys list -n $STORAGE_NAME --resource-group $RESOURCE_GROUP  --query [0].value)

az storage container create -n tfstate --account-name $STORAGE_NAME  --account-key $STORAGE_KEY