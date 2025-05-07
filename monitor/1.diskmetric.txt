#!/bin/bash

az account list --query '[].{subid:id, subname:name }' -o tsv | while read -r subid subname; 
do
	az account set --subscription $subid

	az disk list --query "[].{name:name, resourceGroup:resourceGroup, managedBy:managedBy, diskSizeGb:diskSizeGb, diskIopsReadWrite:diskIopsReadWrite, diskMBpsReadWrite:diskMBpsReadWrite, skuName:sku.name} | [?skuName=='UltraSSD_LRS']" -o tsv > ${subname}-Disk-info.tmp
	echo 获取Disk完成

	az disk list --query "[].{name:name, resourceGroup:resourceGroup, managedBy:managedBy, diskSizeGb:diskSizeGb, diskIopsReadWrite:diskIopsReadWrite, diskMBpsReadWrite:diskMBpsReadWrite, skuName:sku.name} | [?skuName=='UltraSSD_LRS']" -o tsv | while read -r name resourceGroup managedBy diskSizeGb diskIopsReadWrite diskMBpsReadWrite skuName;
	do 
		start_time=`date '+%Y%m%d' -d last-month`
		end_time=`date '+%Y%m%d'`
		read_Bps=`az monitor metrics list --resource $managedBy --resource-group $resourceGroup --metric "Data Disk Read Bytes/Sec" --aggregation Maximum --start-time ${start_time}T00:00:00Z --end-time ${end_time}T00:00:00Z --query value[].timeseries[].data[].maximum -o tsv | sort -n -r | head -n1`
		write_Bps=`az monitor metrics list --resource $managedBy --resource-group $resourceGroup --metric "Data Disk Write Bytes/Sec" --aggregation Maximum --start-time ${start_time}T00:00:00Z --end-time ${end_time}T00:00:00Z --query value[].timeseries[].data[].maximum -o tsv | sort -n -r | head -n1`
		read_IOPS=`az monitor metrics list --resource $managedBy --resource-group $resourceGroup --metric "Data Disk Read Operations/Sec" --aggregation Maximum --start-time ${start_time}T00:00:00Z --end-time ${end_time}T00:00:00Z --query value[].timeseries[].data[].maximum -o tsv | sort -n -r | head -n1`
		write_IOPS=`az monitor metrics list --resource $managedBy --resource-group $resourceGroup --metric "Data Disk Write Operations/Sec" --aggregation Maximum --start-time ${start_time}T00:00:00Z --end-time ${end_time}T00:00:00Z --query value[].timeseries[].data[].maximum -o tsv | sort -n -r | head -n1`

		read_MBps=`echo ${read_Bps}/1024/1024 | bc`
		write_MBps=`echo ${write_Bps}/1024/1024 | bc`
		read_write_MBps=`echo ${read_MBps}+${write_MBps} | bc`
		read_write_IOPS=`echo ${read_IOPS}+${write_IOPS} | bc`

		echo -e "${managedBy}\t${name}\t${resourceGroup}\t${skuName}\t${diskSizeGb}\t${diskIopsReadWrite}\t${diskMBpsReadWrite}\t${read_write_IOPS}\t${read_write_MBps}\t${read_IOPS}\t${write_IOPS}\t${read_MBps}\t${write_MBps}" | tee -a table-UltraUsage.xslx
	done
done 
echo "Complete"
    