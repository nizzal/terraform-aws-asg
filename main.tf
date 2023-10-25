module "vpc" {
  source = "./modules/services/vpc"

}

module "alb_s3_logs" {
  source = "./modules/services/s3"

  # alb_logs_bucket_name = "my-alb-logs-bucket-4712-now"
  # elb_principal_value  = "arn:aws:iam::127311923021:root"
  alb_logs_bucket_name = var.alb_logs_bucket_name
  elb_principal_value = var.elb_principal_value
}

module "alb" {
  source = "./modules/services/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_one = module.vpc.aws_public_subnets[0]
  public_subnet_two = module.vpc.aws_public_subnets[1]
  #alb_bucket_id = module.alb_s3_logs.alb_logs_bucket_url
  alb_bucket_id = module.alb_s3_logs.s3_logs_id

  depends_on = [module.alb_s3_logs]
}

module "web_server_asg" {
  source = "./modules/services/asg"

  vpc_id               = module.vpc.vpc_id
  asg_max_size         = 4
  asg_min_size         = 1
  asg_desired_capacity = 2

  amazon_linux_ami  = "ami-08a52ddb321b32a8c"
  asg_instance_type = "t2.micro"
  asg_instance_key  = "vockey"
  private_subnets   = module.vpc.aws_private_subnets
  alb_tg_arn = module.alb.alb_tg_arn
  asg_sg_ports = [80, 443, 22]
}

module "ec2_bastion_host" {
  source = "./modules/services/ec2"

  instance_vpc_id = module.vpc.vpc_id
  instance_type = "t2.micro"
  instance_key = "vockey"
  instance_subnet = module.vpc.aws_public_subnets[0]
}