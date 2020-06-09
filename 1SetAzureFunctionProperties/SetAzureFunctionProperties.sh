az cloud set --name AzureChinaCloud 
az login

#subs=$(az account list -o table)
subs=$(az account list --query [].id -o tsv)

#Loop each Azure Subscription
for sub in $subs
do
	echo -e 'select subscription...'
	#select each Azure Subscription
	az account set --subscription $sub
	
	#loop each Azure Function
	echo -e 'loop function...'
	
	#funcs=$(az functionapp list --query '[].{id:id,name:name,resourceGroup:resourceGroup}' -o tsv)
	
	az functionapp list --query '[].{id:id,name:name,resourceGroup:resourceGroup}' -o tsv | 
	while read -r id name resourceGroup; do
		echo -e 'set firewall'
		az functionapp config access-restriction add -g $resourceGroup -n $name --rule-name sbuxip --action Allow --ip-address 130.220.0.0/32 --priority 200
		
		
		echo -e 'set SCM firewall'
		az functionapp config access-restriction add -g $resourceGroup -n $name --rule-name sbuxip --action Allow --ip-address 130.220.0.0/32 --priority 200 --scm-site true
		
		
		echo -e 'Set Function HTTPS Only'
		az functionapp update -g $resourceGroup -n $name --set httpsOnly=true
		
		#if((az storage account check-name -n leizhangdiag001 --query "nameAvailable") -eq "true")
			az storage account create -n leizhangdiag003 -g $resourceGroup -l chinaeast2 --sku Standard_LRS
		#fi
	
		
		echo -e 'set Diag'
		#az monitor diagnostic-settings create -n FunctionDiag --resource $id --storage-account leizhangdiag002 --logs FunctionAppLogs --metrics AllMetrics
		
		az monitor diagnostic-settings create -n monitor001 -g $resourceGroup -n FunctionDiag --resource $id --storage-account leizhangdiag003 
		--logs '[
		 {
		   "category": "FunctionAppLogs",
		   "enabled": true,
		   "retentionPolicy": {
			 "enabled": false,
			 "days": 0
		   }
		 }
	   ]'
	   --metrics '[
		 {
		   "category": "AllMetrics",
		   "enabled": true,
		   "retentionPolicy": {
			 "enabled": false,
			 "days": 0
		   }
		 }
	   ]'
		
	done
done

#sed -i -e 's/\r$//' setfunction.sh
