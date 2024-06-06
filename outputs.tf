# output "etcd_eip" {
#   value = format("The etcd server EIP is: %s", aws_eip.etcd-eip.public_ip)
# }

output "public_ip"{
    value = format("The etcd server public ip  is: %s", aws_instance.etcd-server.public_ip)

}