variable "rds_password" {
  description = "password of the RDS DB"
  type        = string
}

variable "cce_sg_id" {
  description = "cce security group password"
  type        = string
}

variable "bastion_sg_id" {
  description = "bastion security group password"
  type        = string
}

variable "subnet_id" {
  description = "subnet id where rds will be created"
  type        = string
}

variable "vpc_id" {
  description = "vpc id where RDS will be created"
  type        = string
}

