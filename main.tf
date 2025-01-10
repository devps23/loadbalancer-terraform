module "frontend" {
  depends_on = [module.backend]
  source = "./modules/app"
  component = "frontend"
  instance_type=var.instance_type
  env = var.env
  zone_id     = var.zone_id
  vault_token = var.vault_token
  subnets_id = module.vpc.frontend_subnets
  vpc_id = module.vpc.vpc_id
}
module "backend" {
  depends_on = [module.mysql]
  source = "./modules/app"
  component = "backend"
  instance_type=var.instance_type
  env = var.env
  zone_id = var.zone_id
  vault_token = var.vault_token
  subnets_id = module.vpc.backend_subnets
  vpc_id = module.vpc.vpc_id
}
module "mysql" {
  source = "./modules/app"
  component = "mysql"
  instance_type=var.instance_type
  env = var.env
  zone_id = var.zone_id
  vault_token = var.vault_token
  vpc_id = module.vpc.vpc_id
  subnets_id = module.vpc.mysql_subnets
}
module "vpc"{
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  env = var.env
  default_vpc_id=var.default_vpc_id
  default_vpc_cidr_block = var.default_vpc_cidr_block
  default_route_table_id = var.default_route_table_id
  frontend_subnets = var.frontend_subnets
  backend_subnets = var.backend_subnets
  mysql_subnets = var.mysql_subnets
  availability_zone = var.availability_zone
  public_subnets = var.public_subnets
}
