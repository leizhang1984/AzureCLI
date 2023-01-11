az account list --query '[].{subid:id, subname:name }' -o tsv | while read -r subid subname; 
do
     az account set --subscription $subid
     az group list --query  '[].{rgname:name }' -o tsv | while read -r rgname; 
     do
                az network lb list -g $rgname --query '[].{lbname:name }' -o tsv | while read -r lbname
                do 
                        if  [[ $lbname == lb* ]]; then
                                echo $lbname
                                az network lb probe list --lb-name $lbname --resource-group $rgname --query '[].{probename:name }' -o tsv | while read -r probename
                                do
                                             az network lb probe update -g $rgname --lb-name $lbname -n $probename --probe-threshold 3
                                done 
                        fi           
                done                 
     done
done 
echo "Complete"