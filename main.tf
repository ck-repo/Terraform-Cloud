#Terraform AWS and Azure Provider Config

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
    }
    azurerm = {
      source  = "hashicorp/azurerm"
   }
  }
}

provider "aws" {
  region                  = "us-east-1"
}

provider "azurerm" {
  features {}
}

#AWS ASG Launch Config
resource "aws_launch_configuration" "Terraform-Demo-AWS-Auto-Scaling-Launch-Config" {

  name                   = var.lc_name
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = var.user_data
  
  root_block_device {
  encrypted              = true
  }
}  

#AWS ASG Config

resource "aws_autoscaling_group" "Terraform-Demo-AWS-Auto-Scaling-Group" {
  name                      = var.asg_name
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.Terraform-Demo-AWS-Auto-Scaling-Launch-Config.name
  vpc_zone_identifier       = ["subnet-1138155b", "subnet-24e97443"]
  load_balancers            = [aws_elb.Terraform-Demo-AWS-ELB.name]

  timeouts {
    delete = "5m"
  }

  tag {
    key                 = "Name"
    value               = "Terraform-Demo"
    propagate_at_launch = true
  }
}

#AWS ELB Config for ASG

resource "aws_elb" "Terraform-Demo-AWS-ELB" {
  name = "terraform-asg-example"
  security_groups = ["sg-0a1a3a4a"]
  availability_zones = ["us-east-1b", "us-east-1d"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}

#Azure Virtual Network Config
resource "azurerm_resource_group" "Terraform-Demo-Azure-RG" {
  name     = "TF-Demo-RG"
  location = var.location
}

resource "azurerm_virtual_network" "Terraform-Demo-Azure-Vnet" {
  name                = "Terraform-Demo-Vnet"
  resource_group_name = azurerm_resource_group.Terraform-Demo-Azure-RG.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "Terraform-Demo-Azure-Subnet" {
  name                 = "Terraform-Demo-Subnet"
  resource_group_name  = azurerm_resource_group.Terraform-Demo-Azure-RG.name
  virtual_network_name = azurerm_virtual_network.Terraform-Demo-Azure-Vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "Terraform-Demo-Azure-NSG" {
  name                = "Terraform-Demo-Azure-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.Terraform-Demo-Azure-RG.name  

  security_rule {
    name                       = "Any-Any"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "Terraform-Demo-Azure-NSG-Association" {
  subnet_id                 = azurerm_subnet.Terraform-Demo-Azure-Subnet.id 
  network_security_group_id = azurerm_network_security_group.Terraform-Demo-Azure-NSG.id 
}

#Azure Virtual Machine Scale Set Config

resource "azurerm_linux_virtual_machine_scale_set" "Terraform-Demo-Azure-VMSS" {
  name                             = "Terraform-Demo-VMSS"
  resource_group_name              = azurerm_resource_group.Terraform-Demo-Azure-RG.name
  location                         = azurerm_resource_group.Terraform-Demo-Azure-RG.location
  sku                              = "Standard_F2"
  instances                        = 2
  admin_username                   = "adminuser"
  admin_password                   = var.VMSS_PASS
  disable_password_authentication  = false
  zone_balance                     = true
  zones                            = [1, 2, 3] 
  custom_data                      = base64encode(file("azure.sh"))

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "default"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.Terraform-Demo-Azure-Subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.Terraform-Demo-Azure-LB-Backend-Pool.id]
    }
  }
}

#Azure LB Config for VMSS

resource "azurerm_public_ip" "Terraform-Demo-Azure-PIP" {
 name                         = "Terraform-Demo-Azure-PIP"
 location                     = var.location
 resource_group_name          = azurerm_resource_group.Terraform-Demo-Azure-RG.name
 allocation_method            = "Static"
 sku                          = "Standard"
 domain_name_label            = "terraform-demo"
}

resource "azurerm_lb" "Terraform-Demo-Azure-LB" {
 name                = "Terraform-Demo-Azure-LB"
 location            = var.location
 resource_group_name = azurerm_resource_group.Terraform-Demo-Azure-RG.name
 sku                 = "Standard"   

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.Terraform-Demo-Azure-PIP.id
 }
}

resource "azurerm_lb_backend_address_pool" "Terraform-Demo-Azure-LB-Backend-Pool" {
 loadbalancer_id     = azurerm_lb.Terraform-Demo-Azure-LB.id
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "Terraform-Demo-Azure-LB-Probe" {
 resource_group_name = azurerm_resource_group.Terraform-Demo-Azure-RG.name
 loadbalancer_id     = azurerm_lb.Terraform-Demo-Azure-LB.id
 name                = "ssh-running-probe"
 port                = "80"
}

resource "azurerm_lb_rule" "Terraform-Demo-Azure-LBNATRule" {
   resource_group_name            = azurerm_resource_group.Terraform-Demo-Azure-RG.name
   loadbalancer_id                = azurerm_lb.Terraform-Demo-Azure-LB.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = "80"
   backend_port                   = "80"
   backend_address_pool_id        = azurerm_lb_backend_address_pool.Terraform-Demo-Azure-LB-Backend-Pool.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.Terraform-Demo-Azure-LB-Probe.id
}