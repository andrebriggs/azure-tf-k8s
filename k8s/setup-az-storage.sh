# Env var checking
[ ! -z "$RESOURCE_GROUP" ] || { echo "Provide RESOURCE_GROUP"; exit 1;}
[ ! -z "$STORAGE_NAME" ] || { echo "Provide STORAGE_NAME"; exit 1;}

# RG Exists?
rg_exists=$(az group exists --name $RESOURCE_GROUP)
if [ rg_exists != "true" ]; then
    echo "$RESOURCE_GROUP doesn't exist. Creating..."
    [ ! -z "$RESOURCE_GROUP_LOCATION" ] || { echo "Provide RESOURCE_GROUP_LOCATION"; exit 1;}
    az group create --name $RESOURCE_GROUP -l $RESOURCE_GROUP_LOCATION
fi

# Create resources
az storage account create --resource-group $RESOURCE_GROUP --name $STORAGE_NAME --sku Standard_LRS
STORAGE_KEY=$(az storage account keys list -n $STORAGE_NAME --resource-group $RESOURCE_GROUP  --query [0].value)
az storage container create -n tfstate --account-name $STORAGE_NAME  --account-key $STORAGE_KEY