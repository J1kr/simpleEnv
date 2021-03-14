variable "name" {
  description = "모듈에서 정의하는 모든 리소스 이름의 prefix"
  type        = string
}

variable "rds_name" {
  description = "database name"
  type        = string
}

variable "rds_username" {
  description = "datebase user"
  type        = string
}

variable "rds_passwd" {
  description = "datebase passwd"
  type        = string
}

variable "subnet_name" {
  description = "Subnet ID"
  type        = string
}

variable "security_groups" {
  description = "security_groups"
  type        = list
}

variable "tags" {
  description = "모든 리소스에 추가되는 tag 맵"
  type        = map
}
