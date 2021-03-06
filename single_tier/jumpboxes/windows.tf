# winJump
# #Storage Container
# resource "azurerm_storage_container" "vhds" {
#   name                  = var.ARM_AZ_STGCONT_VHDS_NAME
#   resource_group_name   = azurerm_resource_group.RGName.name
#   storage_account_name  = azurerm_storage_account.azrmstgacc-stdssdlrs-001.name
#   container_access_type = "private"
# }
#https://www.terraform.io/docs/providers/azurerm/r/network_interface.html

resource azurerm_network_interface winjump-ext-nic {
  name                = "${var.prefix}-winjump-ext-nic"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name
  network_security_group_id = var.securityGroup.id

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnetExternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.winJumpIp
    primary			  = true
  }

  tags = {
    Name           = "${var.environment}-winjump-ext-int"
    environment    = var.environment
    owner          = var.owner
    group          = var.group
    costcenter     = var.costcenter
    application    = "winjump"
  }
}



#https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html 
resource azurerm_virtual_machine winJump {
    name="winJump"
    resource_group_name =   var.resourceGroup.name
    location    =   var.resourceGroup.location
    vm_size = "Standard_B2s" #Information about the Virtual Machines Sizes: https://docs.microsoft.com/nl-be/azure/virtual-machines/windows/sizes-general
    network_interface_ids=[azurerm_network_interface.winjump-ext-nic.id] #Front-End Network
 
    os_profile_windows_config {
        provision_vm_agent=true
        timezone= var.timezone
    }
    #OS Image selection: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
    storage_image_reference  {
        publisher="MicrosoftWindowsServer"
        offer="WindowsServer"
        sku="2016-Datacenter"
        version="latest"
    }
 
    storage_os_disk {
        name          = "winJump-os"
        # vhd_uri       = "${azurerm_storage_account.azrmstgacc-stdssdlrs-001.primary_blob_endpoint}${azurerm_storage_container.vhds.name}/winJumpos.vhd"
        caching       = "ReadWrite"
        create_option = "FromImage"
        os_type       = "Windows"
    }
 
    os_profile {
        computer_name  = "winJump"
        admin_username = var.adminUserName
        admin_password = var.adminPassword
    }
 
  tags = {
    Name           = "${var.environment}-winJump"
    environment    = var.environment
    owner          = var.owner
    group          = var.group
    costcenter     = var.costcenter
    application    = var.application
  }
}