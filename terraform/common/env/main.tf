# module키워드를 사용해서 vpc module을 정의한다.
module "vpc" {
  # source는 variables.tf, main.tf, outputs.tf 파일이 위치한 디렉터리 경로를 넣어준다.
  source = "../../modules/vpc"

  # VPC이름을 넣어준다. 이 값은 VPC module이 생성하는 모든 리소스 이름의 prefix가 된다.
  name = "spoon"
  # VPC의 CIDR block을 정의한다.
  cidr = "10.0.0.0/16"

  # VPC가 사용할 AZ를 정의한다.
  azs              = ["ap-northeast-1a", "ap-northeast-1c"]
  # VPC의 Public Subnet CIDR block을 정의한다.
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  # VPC의 Private Subnet CIDR block을 정의한다.
  private_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]
  # VPC의 Private DB Subnet CIDR block을 정의한다. (RDS를 사용하지 않으면 이 라인은 필요없다.)
  database_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  # VPC module이 생성하는 모든 리소스에 기본으로 입력될 Tag를 정의한다.
  tags = {
    "TerraformManaged" = "true"
  }
}

module "bastion" {
  source = "../../modules/bastion"

  name   = "env"
  vpc_id = module.vpc.vpc_id

  ami                 = data.aws_ami.amazon_linux.id
  availability_zone   = "ap-northeast-1a"
  subnet_id           = module.vpc.public_subnets_ids[0]
  ingress_cidr_blocks = var.office_cidr_blocks
  keypair_name        = var.keypair_name

  tags = {
    "TerraformManaged" = "true"
  }
}

module "ec2" {
  source = "../../modules/ec2"

  name   = "ec2"
  vpc_id = module.vpc.vpc_id

  ami                 = data.aws_ami.amazon_linux.id
  availability_zone   = "ap-northeast-1a"
  subnet_id           = module.vpc.private_subnets_ids[0]

  ingress_cidr_block = module.vpc.vpc_cidr_block
  keypair_name       = var.keypair_name

  tags = {
    "TerraformManaged" = "true"
  }
}


module "alb" {
  source = "../../modules/alb"

  name   = "alb"
  vpc_id = module.vpc.vpc_id
  instance_id = module.ec2.instance_id
  subnet_id = module.vpc.public_subnets_ids[*]

  tags = {
    "TerraformManaged" = "true"
  }
}

module "mysql" {
  source = "../../modules/mysql"

  name   = "rds"
  
  subnet_name = module.vpc.database_subnet_group_name
  rds_name = "myapp"
  rds_username = "root"
  rds_passwd = "dkfwl123"
  security_groups = [module.ec2.internel_sg]

  tags = {
    "TerraformManaged" = "true"
  }
}

