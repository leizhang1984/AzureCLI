#az account set --subscription 

az vm list --query '[].{name:name, resourcegroup:resourceGroup}' -o tsv | while read -r name resourcegroup; 
do 
       Status=$(az vm get-instance-view --name $name --resource-group $resourcegroup --query instanceView.vmAgent.statuses[0].code); 
       if [[ $Status == *Unavailable* ]]; then 
            echo $name; 
       fi; 
done 
echo "Complete"