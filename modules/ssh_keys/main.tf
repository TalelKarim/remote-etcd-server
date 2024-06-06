# Create an SSH key pair
resource "tls_private_key" "etcd_key_pair" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  filename = "./etcd-key-pair.pem" # Change the path as needed
  content  = tls_private_key.etcd_key_pair.private_key_pem
}

resource "aws_key_pair" "key_pair" {
  key_name   = "etcd-key-pair"
  public_key = tls_private_key.etcd_key_pair.public_key_openssh
}

resource "null_resource" "set_file_permissions" {
  provisioner "local-exec" {
    command = "chmod 400 ./etcd-key-pair.pem"
  }

  triggers = {
    local_file_content = local_file.private_key.content
  }
}

