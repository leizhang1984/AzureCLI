#!/bin/bash

# 定义文件路径
file_path="privateips.txt"

# 检查文件是否存在
if [ ! -f "$file_path" ]; then
  echo "文件 $file_path 不存在。"
  exit 1
fi

while IFS= read -r line; do
    # 移除行末的换行符或回车符
    line=$(echo "$line" | tr -d '\r')

    # 给IP地址添加单引号
    privateip="'$line'"

    echo "找到内网IP地址是: "$privateip

    explorer_query="resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | extend nics = properties.networkProfile.networkInterfaces
    | mvexpand nics
    | extend nicId = tostring(nics.id)
    | join kind=inner (
        resources
        | where type =~ 'microsoft.network/networkinterfaces'
        | extend ipConfigs = properties.ipConfigurations
        | mvexpand ipConfigs
        | extend privateIp = tostring(ipConfigs.properties.privateIPAddress)
        | project nicId = id, privateIp
    ) on nicId
    | project id, vmName = name, resourceGroup, subscriptionId, privateIp
    | where privateIp contains $privateip"

    
    echo $explorer_query
    # query_result=$(az graph query -q $explorer_query")
    query_result=$(az graph query --graph-query "$explorer_query" --query "data")

    # 检查是否找到虚拟机
    if [ -n "$query_result" ]; then
      echo "找到虚拟机"
    else
      echo "没有找到与内网 IP 地址 $ip 关联的虚拟机。"
      continue
    fi

    vm_id=$(echo "$query_result" | grep -o '"id": "[^"]*' | grep -o '/subscriptions[^"]*')
    echo "找到的虚拟机 ID: $vm_id"
    
    if [ -n "$vm_id" ]; then
      # Not Delete
      az lock create --lock-type CanNotDelete --name CanNotDelete --resource $vm_id --output none
      
      # Read Only
      az lock create --lock-type ReadOnly  --name ReadOnly --resource $vm_id --output none
    else
      echo "没有找到虚拟机 ID: $vm_id"
    fi
done < "$file_path"
echo '执行完成。'

