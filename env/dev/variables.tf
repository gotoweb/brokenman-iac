variable "name" {
  type = string
  default = "brokenman-dev"
}

variable "ipv4_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "container_port" {
  type = string
  default = 80
}

variable "container_uri" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type = string
}

variable "database_hostname" {
  type = string
}