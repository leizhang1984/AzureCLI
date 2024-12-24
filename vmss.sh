#获取VMSS
az vmss list-instances -g sig-rg -n leivmss02 --query "[].{name:name, resourceGroup:resourceGroup}" -o tsv | while read -r name resourceGroup
do

	az vm get-instance-view --resource-group $resourceGroup --name $name --query "{name: name,status: instanceView.statuses[1].code}" -o tsv

done 
