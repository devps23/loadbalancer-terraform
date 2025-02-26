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
  lb_internal_facing = "public"
  lb_subnets = module.vpc.public_subnets
  lb_required = true
  app_port = 80
#   bastion_nodes = var.bastion_nodes
#   server app port subnet depends from bottom to top
#   server_app_port_cidr = var.public_subnets
#   load balancer app port cidr from top to bottom
#    lb_app_port_cidr = ["0.0.0.0/0"]
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
  lb_internal_facing = "private"
  lb_subnets = module.vpc.backend_subnets
  lb_required = true
  app_port = 8080
#   bastion_nodes = var.bastion_nodes
#   server_app_port_cidr = concat(var.frontend_subnets,var.backend_subnets)
#   load balancer port cidr connects with backend subnets
#   lb_app_port_cidr = var.frontend_subnets
}
module "mysql" {
  source            = "./modules/app"
  component         = "mysql"
  instance_type=var.instance_type
  env = var.env
  zone_id = var.zone_id
  vault_token = var.vault_token
  vpc_id = module.vpc.vpc_id
  subnets_id = module.vpc.mysql_subnets
#   bastion_nodes = var.bastion_nodes
#   server_app_port_cidr = var.backend_subnets
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
