
Terraform module &amp; simple app

## terraform 

### Install
install [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli, "terraform install")   
install [awscli](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-chap-install.html, "awscli install")
### AWS configure
aws configure
### Make InfraStructure by terraform
$cd simpleEnv/terraform/common/env/   
$terraform init   
$terraform plan   
$terraform apply    

## App (Terraform으로 생성된 ec2-Private에서)

### Using app
$cd simpleEnv/app/   
$vim docker-compose.yml
    ```line 29 MYSQL_HOST: "host" -> 위에서 만든 "aws_db_instance.address" ```   
$sh start.sh   


