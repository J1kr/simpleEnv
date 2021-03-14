# module키워드를 사용해서 vpc module을 정의한다.
module "vpc" {
  # source는 variables.tf, main.tf, outputs.tf 파일이 위치한 디렉터리 경로를 넣어준다.
  source = "../../modules/vpc"

  # VPC이름을 넣어준다. 이 값은 VPC module이 생성하는 모든 리소스 이름의 prefix가 된다.
  name = "spoon"
  # VPC의 CIDR block을 정의한다.
  cidr = "20.0.0.0/16"

  # VPC가 사용할 AZ를 정의한다.
  azs              = ["ap-northeast-2a", "ap-northeast-2c"]
  # VPC의 Public Subnet CIDR block을 정의한다.
  public_subnets   = ["20.0.1.0/24", "20.0.2.0/24"]
  # VPC의 Private Subnet CIDR block을 정의한다.
  private_subnets  = ["20.0.10.0/24", "20.0.11.0/24"]
  # VPC의 Private DB Subnet CIDR block을 정의한다. (RDS를 사용하지 않으면 이 라인은 필요없다.)
  database_subnets = ["20.0.101.0/24", "20.0.102.0/24"]

  # VPC module이 생성하는 모든 리소스에 기본으로 입력될 Tag를 정의한다.
  tags = {
    "TerraformManaged" = "true"
  }
}

module "bastion" {
  source = "../../modules/bastion"

  name   = "env"
  
  # 다른 module을 통해 생성된 값을 가져온다. module 내 Output 값을 넣어준다. 
  vpc_id = module.vpc.vpc_id
  # 사용될 AMI를 가져온다 data 형식으로 common_env_variables.tf에서 값을 참조한다.
  ami                 = data.aws_ami.amazon_linux.id
  availability_zone   = "ap-northeast-2a"
  subnet_id           = module.vpc.public_subnets_ids[0]
  # Bastion에 접속될 IP를 가져온다.
  ingress_cidr_blocks = var.office_cidr_blocks
  # Ec2 접속에 사용되는 Keypair를 가져온다.
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
  availability_zone   = "ap-northeast-2a"
  subnet_id           = module.vpc.private_subnets_ids[0]
  # Vpc내 Subnet의 통신을 위해 가져온다. 
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
  # ALB에 연결될 EC2의 ID를 가져온다. 
  instance_id = module.ec2.instance_id
  # ALB가 생성될 Subnet을 가져온다. 외부와 통신하기 때문에 Public 망을 이용한다.  
  subnet_id = module.vpc.public_subnets_ids[*]

  tags = {
    "TerraformManaged" = "true"
  }
}

module "mysql" {
  source = "../../modules/mysql"

  name   = "rds"

  # VPC의 Moudle 에서 생성된 Private DB Subnet name을 가져온다.
  subnet_name = module.vpc.database_subnet_group_name
  # 일반적인 상황에 이렇게 노출하면 안됩니..다.
  rds_name = "myapp"
  rds_username = "root"
  rds_passwd = "dkfwl123"
  # Vpc내 Subnet의 통신을 위해 가져온 SG를 이용한다.
  security_groups = [module.ec2.internel_sg]

  tags = {
    "TerraformManaged" = "true"
  }
}

