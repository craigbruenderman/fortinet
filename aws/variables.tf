variable "aws_region" {
  default = "us-east-1"
}

variable "s3_bucket_name" {
  type    = string
  default = "fgt-poc-tfbackend-bucket"
}

// Availability zones for the region
variable "az1" {
  default = "us-east-1a"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "payg"
}

// BYOL License format to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either token or file.
variable "license_format" {
  default = "file"
}

// Either arm or x86
variable "arch" {
  default = "x86"
}

// use s3 bucket for bootstrap
// Either true or false
variable "bucket" {
  type    = bool
  default = "false"
}

// c5.xlarge is x86_64
variable "size" {
  default = "c5.xlarge"
}

//  Existing SSH Key on the AWS 
variable "keyname" {
  default = "aws-cbts-lab"
}

variable "adminsport" {
  default = "8443"
}

variable "bootstrap-fgtvm" {
  // Change to your own path
  type    = string
  default = "fg-vm.conf.tftpl"
}

// license file for the active fgt
variable "license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "license.lic"
}