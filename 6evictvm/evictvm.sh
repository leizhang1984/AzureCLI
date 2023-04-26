subid='f0a0d925-df4f-4fcf-847c-9d9b746cf9e5'
az account set --subscription $subid

rgname='spot-rg'

az vm list -g spot-rg  --query "[?priority=='Spot'].{name:name}" -o tsv | while read -r name; 
do
        az vm simulate-eviction --resource-group $rgname --name $name
done
echo "Complete"

