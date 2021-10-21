output "aws_elb_dns_name" {
  value = aws_elb.Terraform-Demo-AWS-ELB.dns_name
}

output "azure_lb_dns_name" {
  value = azurerm_public_ip.Terraform-Demo-Azure-PIP.fqdn
}