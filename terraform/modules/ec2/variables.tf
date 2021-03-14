variable "name" {
  description = "모듈에서 정의하는 모든 리소스 이름의 prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ami" {
  description = " 생성에 사용할 AMI"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3a.micro" 
}

variable "availability_zone" {
  description = "EC2 instance availability zone"
  type        = string
}

variable "subnet_id" {
  description = "EC2 instance Subnet ID"
  type        = string
}

variable "keypair_name" {
  description = "keypair name"
  type        = string
}


variable "ingress_cidr_block" {
  description = " SSH 접속을 허용할 CIDR block 리스트"
  type        = string
}


variable "tags" {
  description = "모든 리소스에 추가되는 tag 맵"
  type        = map
}
