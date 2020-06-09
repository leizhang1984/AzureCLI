az cloud set --name AzureChinaCloud 
az login

#subs=$(az account list -o table)
subs=$(az account list --query [].id -o tsv)

#Loop each Azure Subscription
for sub in $subs
do
	#select each Azure Subscription
	az account set --subscription $sub
	
	#loop each Azure Function
	funcs=$(az functionapp list --query '[].{id:id,name:name,resourceGroup:resourceGroup}')
	
	for func in $functions
	do
		#set firewall
		az functionapp config access-restriction add -g $func.resourceGroup -n $func.name `
		--rule-name sbuxip --action Allow --ip-address 130.220.0.0/32 --priority 200
		
		#set SCM firewall
		az functionapp config access-restriction add -g $func.resourceGroup -n $func.name `
		--rule-name sbuxip --action Allow --ip-address 130.220.0.0/32 --priority 200 --scm-site true
		
		#Set Function HTTPS Only
		az functionapp update -g $func.resourceGroup -n $func.name --set httpsOnly=true
		
		#Create Storage account
		az storage account create -n leizhangdiagaccount -g $func.resourceGroup -l chinaeast2 `
		--sku Standard_LRS
		
		
		#set Diag
		az monitor diagnostic-settings create -n FunctionDiag --resource $func.id `
		--storage-account leizhangdiagaccount
		--logs '[
		 {
		   "category": "WorkflowRuntime",
		   "enabled": true,
		   "retentionPolicy": {
			 "enabled": false,
			 "days": 0
		   }
		 }
	   ]'
	   --metrics '[
		 {
		   "category": "WorkflowRuntime",
		   "enabled": true,
		   "retentionPolicy": {
			 "enabled": false,
			 "days": 0
		   }
		 }
	   ]'
	done
	
	
done
