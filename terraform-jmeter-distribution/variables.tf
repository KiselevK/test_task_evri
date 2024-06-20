#Jmeter ec2 instances configuration 

variable "region" {
  description = "region"
  default     = "eu-central-1"
}

variable "AWS_AMI_NAME" {
  description = "Ubuntu Version name"
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "open_ports" {
  description = "ports opened"
  default     = ["80", "22", "1099"]

}

variable "test_type" {
  default = "script_debuging"
}

variable "server_ec2_size_base_on_test_type" {
  default = {
    "script_debuging"    = "t2.micro"
    "distribut_debuging" = "t2.micro"
    "load"               = "c4.xlarge"
    "stresss"            = "c4.xlarge"
    "soak"               = "c4.large"
  }
}

variable "client_ec2_size_base_on_test_type" {
  default = {
    "script_debuging"    = "t2.micro"
    "distribut_debuging" = "t2.micro"
    "load"               = "c4.xlarge"
    "stresss"            = "c4.xlarge"
    "soak"               = "c4.large"
  }
}

variable "number_of_server_instances" {
  default = {
    "script_debuging"    = 0
    "distribut_debuging" = 1
    "load"               = 5
    "stresss"            = 10
    "soak"               = 5
  }
}

variable "tags" {
  default = {
    "Owner" = "Perf team"
    "Env"   = "Testing"
  }

}

#----------JMETER CONFIGURATION
variable "jvm_args" {
  default = "-Xms90m -Xmx90m"
  type    = string
}

variable "jmeter_version" {
  description = "Jmeter version for provision"
  default     = "5.6.3"
}

variable "test_args" {
  description = ""
  default     = "-optionToRun 3"
}
