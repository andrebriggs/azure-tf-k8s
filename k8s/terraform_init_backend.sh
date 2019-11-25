# Env var checking
[ ! -z "$RESOURCE_GROUP" ] || { echo "Provide RESOURCE_GROUP"; exit 1;}
[ ! -z "$STORAGE_NAME" ] || { echo "Provide STORAGE_NAME"; exit 1;}

echo "Retrieving storage key for storage account $STORAGE_NAME in resource group $RESOURCE_GROUP"
STORAGE_KEY=$(az storage account keys list -n $STORAGE_NAME --resource-group $RESOURCE_GROUP  --query [0].value)

echo "About to execute terraform init with backend config in $STORAGE_NAME"
terraform init -backend-config="storage_account_name=$STORAGE_NAME" -backend-config="container_name=tfstate" -backend-config="access_key=$(echo "$STORAGE_KEY" | tr -d '"')" -backend-config="key=codelab.microsoft.tfstate"