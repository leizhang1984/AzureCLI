read -p "Enter Service Principal Display Name:" spname
#echo $spname


az ad sp list --filter "displayname eq '$spname'" --query '[].{appDisplayName:appDisplayName,appId:appId,id:id}' -o tsv   | while read -r displayName appId id;
do
     #echo $displayName
     echo "对应的ID是 " $id

     az ad group list --query '[].{displayName:displayName,id:id}' -o tsv | while read -r displayName id;
     do
	     echo "用户组" $displayName "包含的App ID有 "
	     #echo $id

             az rest \
               --method get \
               --url https://graph.microsoft.com/beta/groups/$id/members |\
               jq '.value[] | select(.["@odata.type"] == "#microsoft.graph.servicePrincipal") | .id'
     done
done



