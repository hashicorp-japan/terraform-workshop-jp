terraform {
	required_version = " 0.12.6"
}

provider "aws" {
	access_key = var.access_key
	secret_key = var.secret_key
	region = var.region
}

resource "aws_instance" "hello-tf-instance" {
	ami = var.ami
	count = var.hello_tf_instance_count
	instance_type = var.hello_tf_instance_type
}
