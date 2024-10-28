#image gallery所在的资源组名称
resourcegroup_name="sig-rg"

#gallert 名称
gallery_name="nio_image_template_fk"

#image definition name，请先提前创建好
image_definition="centos8.2"

#新的version name
image_version="0.0.2"

#找到虚拟机操作系统盘的资源id
osdisk_resourceid="/subscriptions/166157a8-9ce9-400b-91c7-1d42482b83d6/resourceGroups/sig-rg/providers/Microsoft.Compute/disks/leicentos8.2-new_OsDisk_1_d8ca0a3a8802494594c0974bc8a00ac3"

az sig image-version create --resource-group $resourcegroup_name --gallery-name $gallery_name --gallery-image-definition $image_definition --gallery-image-version $image_version --os-snapshot $osdisk_resourceid