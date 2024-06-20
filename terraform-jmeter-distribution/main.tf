provider "aws" {
  region = var.region
}


data "aws_ami" "get_latest_ubuntu22" {
  provider    = aws
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = [var.AWS_AMI_NAME]
  }
}


resource "aws_default_vpc" "default" {}

resource "aws_security_group" "jmeter_network" {
  vpc_id = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = var.open_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 4000
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "jmeter_instance_pem" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "Test"
  public_key = tls_private_key.jmeter_instance_pem.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.jmeter_instance_pem.private_key_pem}' > ./Test.pem && chmod 400 Test.pem"

  }
}


resource "aws_instance" "jmeter_server_instance" {
  count                  = lookup(var.number_of_server_instances, var.test_type)
  instance_type          = lookup(var.client_ec2_size_base_on_test_type, var.test_type)
  key_name               = aws_key_pair.generated_key.key_name
  ami                    = data.aws_ami.get_latest_ubuntu22.image_id
  vpc_security_group_ids = [aws_security_group.jmeter_network.id]
  depends_on             = [aws_key_pair.generated_key]
  tags                   = merge({ "Name" : "Jmeter Server ${count.index + 1}", "Test type" = var.test_type }, var.tags)

  user_data = templatefile("server_user_data.sh.tpl", {
    JMETER_VERSION = var.jmeter_version
  })
}


resource "aws_instance" "jmeter_client_instance" {
  instance_type          = lookup(var.client_ec2_size_base_on_test_type, var.test_type)
  key_name               = aws_key_pair.generated_key.key_name
  ami                    = data.aws_ami.get_latest_ubuntu22.image_id
  vpc_security_group_ids = [aws_security_group.jmeter_network.id]
  depends_on             = [aws_key_pair.generated_key]
  tags                   = merge({ "Name" : "Jmeter Client", "Test type" = var.test_type }, var.tags)

  user_data = templatefile("client_user_data.sh.tpl", {
    JMETER_VERSION         = var.jmeter_version,
    private_server_key_pem = tls_private_key.jmeter_instance_pem.private_key_pem
  })
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for /home/ubuntu/jmeter directory to be created...'",
      "while [ ! -f /home/ubuntu/jmeter/bin/rmi_keystore.jks ]; do sleep 10; done",
      "echo 'Directory /home/ubuntu/jmeter is now available.'",
      "echo 'Waiting for /home/ubuntu/jmeter/bin/rmi_keystore.jks to have owner ubuntu...'",
      "while [ $(stat -c %U /home/ubuntu/jmeter/bin/rmi_keystore.jks) != 'ubuntu' ]; do sleep 10; done",
      "echo 'File /home/ubuntu/jmeter/bin/rmi_keystore.jks now has owner ubuntu.'"

    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jmeter_instance_pem.private_key_pem
      host        = self.public_dns
    }
  }

  provisioner "file" {
    source      = "../src"
    destination = "/home/ubuntu"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jmeter_instance_pem.private_key_pem
      host        = self.public_dns
    }
  }
}

locals {
  jmeter_servers = {
    for idx, instance in aws_instance.jmeter_server_instance :
    idx => {
      id        = instance.id,
      public_ip = instance.public_ip
    }
  }

  jmeter_server_ips = length(local.jmeter_servers) > 0 ? "-R " + join(",", [for server in local.jmeter_servers : server.public_ip]) : ""


}

resource "null_resource" "setup_jmeter_servers" {
  depends_on = [
    aws_instance.jmeter_client_instance,
    aws_instance.jmeter_server_instance,
    aws_key_pair.generated_key
  ]

  for_each = local.jmeter_servers

  # Copy ssl key from client jmeter to servers for secure conection
  provisioner "remote-exec" {
    inline = [
      "scp -i ~/.ssh/Test.pem -o StrictHostKeyChecking=no  /home/ubuntu/jmeter/bin/rmi_keystore.jks ubuntu@${each.value.public_ip}:/home/ubuntu/jmeter/bin/rmi_keystore.jks"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jmeter_instance_pem.private_key_pem
      host        = aws_instance.jmeter_client_instance.public_ip
    }
  }
  # start jmeter server on servers
  provisioner "remote-exec" {
    inline = [
      "JVM_ARGS=\"${var.jvm_args}\" && export JVM_ARGS",
      "screen -dmS jmeter_session bash -c '/home/ubuntu/jmeter/bin/jmeter-server -Dserver.rmi.ssl.keystore.file=/home/ubuntu/jmeter/bin/rmi_keystore.jks -Dserver.rmi.localport=50000 -Dserver_port=1099'",
      "sleep 5"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jmeter_instance_pem.private_key_pem
      host        = each.value.public_ip
    }
  }

}

resource "null_resource" "start_jmeter_test" {
  depends_on = [null_resource.setup_jmeter_servers]
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sleep 10s",
      "chmod -R 775 src",
      "cd src",
      "export JMETER_PATH=/home/ubuntu/jmeter/bin/jmeter",
      "JVM_ARGS=\"${var.jvm_args}\" && export JVM_ARGS",
      "screen -dmS jmeter_session bash -c './jmeter_test.sh ${var.test_args} ${local.jmeter_server_ips} > /home/ubuntu/jmeter-clien.log 2>&1'",
      "sleep 5s"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jmeter_instance_pem.private_key_pem
      host        = aws_instance.jmeter_client_instance.public_ip
    }
  }
}

