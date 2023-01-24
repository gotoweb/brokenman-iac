variable "engine" {}
variable "engine_mode" {
  default = null # "provisioned"
}
variable "engine_version" {
  default = null
}

variable "name" {}
variable "vpc" {}
variable "subnets" {}
variable "instance_class" {}

variable "database_name" {}
variable "master_username" { }
variable "master_password" {}

variable "serverlessv2_scaling_configuration" {}