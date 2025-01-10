# create an instance
resource "aws_instance" "instance" {
  ami = data.aws_ami.ami.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = var.subnets_id[0]
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }
  tags = {
    Name = "${var.env}-${var.component}-demo"
    monitor = "yes"

  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

# create a security group
resource "aws_security_group" "sg" {
  name        = "${var.env}-vsg-${var.component}"
  description = "${var.env}-vsg-${var.component}"
  vpc_id      = var.vpc_id
  ingress {
    from_port   =  0
    to_port     =  0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   =  0
    to_port     =  0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-vsg-${var.component}"
  }
}

# resource "null_resource" "null_instance" {
#   connection {
#     type     = "ssh"
#     user     = jsondecode(data.vault_generic_secret.my_secret.data_json).username
#     password = jsondecode(data.vault_generic_secret.my_secret.data_json).password
#     host     = aws_instance.instance.private_ip
#
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo dnf install ansible -y",
#       "sudo pip3.11 install ansible hvac",
#       "ansible-pull -i localhost, -U https://github.com/devps23/expense-practice-ansible get-secrets.yml -e env=${var.env} -e component_name=${var.component} -e vault_token=${var.vault_token}",
#       "ansible-pull -i localhost, -U https://github.com/devps23/expense-practice-ansible expense.yml -e env=${var.env} -e component_name=${var.component} -e @~/secrets.json -e @~/app.json"
#     ]
#   }
# }
resource "aws_route53_record" "record" {
  name      = "${var.component}-${var.env}"
  type      = "A"
  zone_id   = var.zone_id
  ttl       = 5
  records = [aws_instance.instance.private_ip]
}
# create load balancer
resource "aws_lb" "lb" {
  count              = var.lb_required ? 1 : 0
  name               = "${var.env}-${var.component}-lb"
  internal           = var.lb_internal_facing == "public" ? false : true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.lb_subnets
   tags = {
    Environment = "${var.env}-${var.component}-lb"
  }
}
# create target group
resource "aws_lb_target_group" "tg" {
  count              = var.lb_required ? 1 : 0
  name               = "${var.env}-${var.component}-tg"
  port               = var.app_port
  protocol           = "HTTP"
  vpc_id             = var.vpc_id
  tags = {
    Name = "${var.env}-${var.component}-tg"
  }
}
# target group attachment
resource "aws_lb_target_group_attachment" "tg_attachment" {
  count              = var.lb_required ? 1 : 0
  target_group_arn = aws_lb_target_group.test[0].arn
  target_id        = aws_instance.instance.id
  port             = var.app_port
}



