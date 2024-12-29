#!/usr/bin/bash

read -p "Enter the resource group name: " resgroup
read -p "Enter the storage account name: " stgacct
read -p "Enter the container name: " ctname
read -p "Enter the batch account name: " btacct

echo "Resource Group: $resgroup"
echo "Storage Account: $stgacct"
echo "Container Name: $ctname"
echo "Batch Account: $btacct"

export resgroup
export stgacct
export ctname
export btacct

# Get date 5 days from today
export expiry_date=`date -u -d "+5 days" '+%Y-%m-%dT%H:%MZ'`

# get the storage account key and storage endpoint
export stgkey=$(az storage account keys list -g $resgroup -n $stgacct -o tsv | head -n1 | cut -f 4)
export stgurl=$(az storage account show-connection-string -g $resgroup -n $stgacct --protocol https -o tsv | cut -f5,9 -d ';' | cut -f 2 -d '=')

# get a storage account SAS token to use for AZ_BLOB_ACCOUNT_URL
export sas=$(az storage account generate-sas --account-name $stgacct \
   --account-key $stgkey \
   --expiry $expiry_date \
   --https-only \
   --permissions acdlrw \
   --resource-types sco \
   --services bf \
   --out tsv)

# construct a blob account url with SAS token
export storage_account_url_with_sas="${stgurl}?${sas}"

az storage blob upload-batch -d $ctname --account-name $stgacct --account-key $stgkey -s resources --destination-path resources
az storage blob upload-batch -d $ctname --account-name $stgacct --account-key $stgkey -s workflow --destination-path workflow

export accountname="${btacct}"

# get batch account url from command line
export batch_endpoint=$(az batch account show --name $accountname --resource-group $resgroup --query "accountEndpoint" --output tsv)
export batch_account_url="https://${batch_endpoint}"

# set the batch account key
export az_batch_account_key=$(az batch account keys list --resource-group $resgroup --name $accountname -o tsv | head -n1 | cut -f2)

export AZ_BLOB_ACCOUNT_URL="${storage_account_url_with_sas}"
export AZ_BATCH_ACCOUNT_KEY="${az_batch_account_key}"

export AZ_BLOB_PREFIX="${ctname}"
export AZ_BATCH_ACCOUNT_URL="${batch_account_url}"
export AZ_BATCH_ACCOUNT_KEY="${az_batch_account_key}"
export AZ_BLOB_ACCOUNT_URL="${storage_account_url_with_sas}"

cd workflow

snakemake --jobs 3 -rpf --verbose --default-remote-prefix $AZ_BLOB_PREFIX --use-conda --default-remote-provider AzBlob --envvars AZ_BLOB_ACCOUNT_URL --az-batch --container-image  huangxlab/lai-image --az-batch-account-url $AZ_BATCH_ACCOUNT_URL

az storage blob download --account-name $stgacct --container-name $ctname --name results/plots/b1.scores.png --file b1.scores.png

# clean files in blob storage
az storage blob delete-batch --account-name $stgacct --source $ctname
