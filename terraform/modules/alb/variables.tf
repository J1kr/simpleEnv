variable "name" {
  description = "모듈에서 정의하는 모든 리소스 이름의 prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "instance_id" {
  description = "타겟그룹에 연결될 EC2"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = list
}

variable "tags" {
  description = "모든 리소스에 추가되는 tag 맵"
  type        = map
}
