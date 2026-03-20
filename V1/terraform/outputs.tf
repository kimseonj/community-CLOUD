output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "monitoring_security_group_id" {
  value = aws_security_group.monitoring.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "app_instance_id" {
  value = aws_instance.app.id
}

output "monitoring_instance_id" {
  value = aws_instance.monitoring.id
}

output "mysql_instance_id" {
  value = aws_instance.mysql.id
}

output "redis_instance_id" {
  value = aws_instance.redis.id
}

output "app_public_ip" {
  value = aws_eip.app.public_ip
}

output "app_eip_allocation_id" {
  value = aws_eip.app.id
}

output "monitoring_public_ip" {
  value = aws_instance.monitoring.public_ip
}

output "mysql_public_ip" {
  value = aws_instance.mysql.public_ip
}

output "redis_public_ip" {
  value = aws_instance.redis.public_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}

output "monitoring_private_ip" {
  value = aws_instance.monitoring.private_ip
}

output "mysql_private_ip" {
  value = aws_instance.mysql.private_ip
}

output "redis_private_ip" {
  value = aws_instance.redis.private_ip
}

output "app_ami_id" {
  value = var.app_ami_id
}

output "monitoring_ami_id" {
  value = var.monitoring_ami_id
}

output "mysql_ami_id" {
  value = var.mysql_ami_id
}

output "redis_ami_id" {
  value = var.redis_ami_id
}

output "key_pair_name" {
  value = aws_key_pair.main.key_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.main.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.main.arn
}

output "app_iam_role_name" {
  value = aws_iam_role.app_ec2_role.name
}

output "app_instance_profile_name" {
  value = aws_iam_instance_profile.app.name
}

output "ecr_repository_back_name" {
  value = aws_ecr_repository.community_back.name
}

output "ecr_repository_back_url" {
  value = aws_ecr_repository.community_back.repository_url
}

output "ecr_repository_front_name" {
  value = aws_ecr_repository.community_front.name
}

output "ecr_repository_front_url" {
  value = aws_ecr_repository.community_front.repository_url
}

output "deploy_iam_user_name" {
  value = aws_iam_user.deploy.name
}

output "deploy_iam_access_key_id" {
  value = aws_iam_access_key.deploy.id
}

output "deploy_iam_secret_access_key" {
  value     = aws_iam_access_key.deploy.secret
  sensitive = true
}
