resourcegroupname="defaultrg"
vmssname="dpd-insight-azeu-hadoop-dn-prod-00"

az vm list --query "[?virtualMachineScaleSet!=null && contains(virtualMachineScaleSet.id,'"$vmssname"')].{resourceGroup:resourceGroup,name:name}" -o tsv | while read -r resourceGroup name
do 
	az vm show -g $resourceGroup -n $name -d --query privateIps -o tsv
done
echo "complete"
