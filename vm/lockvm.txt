#!/bin/bash

# 定义文件路径
file_path="privateips.txt"

# Resource Group Name
#rgname="sig-rg"

# 登录 Azure
#az login

# 使用 while 循环和 read 命令逐行读取文件内容
while IFS= read -r ip
do
  # 查找与 IP 地址对应的网络接口
  nic_id=$(az network nic list --query "[?ipConfigurations[0].privateIPAddress=='$ip'].id" -o tsv)
  
  if [ -n "$nic_id" ]; then
    # 查找与网络接口对应的虚拟机
    vm_id=$(az vm list --query "[?networkProfile.networkInterfaces[0].id=='$nic_id'].id" -o tsv)
    
    if [ -n "$vm_id" ]; then
      
      # Not Delete
      az lock create --lock-type CanNotDelete --name CanNotDelete --resource $vm_id --output none
      
      # Read Only
      az lock create --lock-type ReadOnly  --name ReadOnly --resource $vm_id --output none
    else
      echo "No VM found with VM ID: $vm_id"
    fi
  else
    echo "No NIC found with IP: $ip"
  fi
done < "$file_path"
echo 'Execute Complete.'
