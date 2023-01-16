 # variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "3"
}

variable "app_name" {
  default     = "Jenkins"
}

variable "app_environment" {
  default     = "prod"
}

variable "health_check_path" {
  default = "/login"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}