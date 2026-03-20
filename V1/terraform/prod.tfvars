project_name             = "community-v1"
project_tag              = "community"
environment              = "prod"
az                       = "ap-northeast-2a"
vpc_cidr                 = "10.0.0.0/16"
public_subnet_cidr       = "10.0.1.0/24"
instance_type            = "t4g.small"
app_ami_id               = "ami-04f06fb5ae9dcc778"
monitoring_instance_type = "t4g.small"
monitoring_ami_id        = "ami-04f06fb5ae9dcc778"
mysql_instance_type      = "t4g.small"
mysql_ami_id             = "ami-04f06fb5ae9dcc778"
redis_instance_type      = "t4g.small"
redis_ami_id             = "ami-04f06fb5ae9dcc778"

# Replace with your current public IP CIDR
ssh_ingress_cidr = "0.0.0.0/0"

# Keep open for initial test, then narrow it later
app_ingress_cidr        = "0.0.0.0/0"
monitoring_ingress_cidr = "0.0.0.0/0"
db_ingress_cidr         = "211.234.58.66/32"

# Use an absolute path
public_key_path           = "/Users/kimsj/.ssh/clay-key.pub"
s3_bucket_name            = "jongju-mate-clay"
ecr_repository_back_name  = "community-back"
ecr_repository_front_name = "community-front"
deploy_iam_user_name      = "community-deployer"
app_deploy_target         = "community-app"
monitoring_deploy_target  = "community-monitoring"
mysql_deploy_target       = "community-mysql"
redis_deploy_target       = "community-redis"

common_tags = {
  Owner = "clay"
}
