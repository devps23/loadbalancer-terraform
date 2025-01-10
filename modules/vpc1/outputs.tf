output "vpc_id"{
  value = aws_vpc.dev.id
}
output "frontend_subnets" {
  value = aws_subnet.frontend.*.id
}
# output "backend_subnets" {
#   value = aws_subnet.backend_subnets.*.id
# }
# output "mysql_subnets" {
#   value = aws_subnet.mysql_subnets.*.id
# }
