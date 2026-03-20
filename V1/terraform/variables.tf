variable "project_name" {
  description = "Project prefix used in resource names and tags"
  type        = string
  default     = "community-v1"
}

variable "project_tag" {
  description = "Project tag value used for operational targeting"
  type        = string
  default     = "community"
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "prod"
}

variable "az" {
  description = "Single AZ to use"
  type        = string
  default     = "ap-northeast-2a"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "App instance type"
  type        = string
  default     = "t4g.small"
}

variable "app_ami_id" {
  description = "AMI ID for app instance (Seoul, Ubuntu 24.04 ARM64)"
  type        = string
  default     = "ami-04f06fb5ae9dcc778"
}

variable "monitoring_instance_type" {
  description = "Monitoring instance type"
  type        = string
  default     = "t4g.small"
}

variable "monitoring_ami_id" {
  description = "AMI ID for monitoring instance (Seoul, Ubuntu 24.04 ARM64)"
  type        = string
  default     = "ami-04f06fb5ae9dcc778"
}

variable "mysql_instance_type" {
  description = "MySQL instance type"
  type        = string
  default     = "t4g.small"
}

variable "mysql_ami_id" {
  description = "AMI ID for MySQL instance (Seoul, Ubuntu 24.04 ARM64)"
  type        = string
  default     = "ami-04f06fb5ae9dcc778"
}

variable "redis_instance_type" {
  description = "Redis instance type"
  type        = string
  default     = "t4g.small"
}

variable "redis_ami_id" {
  description = "AMI ID for Redis instance (Seoul, Ubuntu 24.04 ARM64)"
  type        = string
  default     = "ami-04f06fb5ae9dcc778"
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH to app instance (recommended: your public IP/32)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_ingress_cidr" {
  description = "CIDR allowed for app ports 80,443,8080"
  type        = string
  default     = "0.0.0.0/0"
}

variable "monitoring_ingress_cidr" {
  description = "CIDR allowed for Grafana and Prometheus (3000,9090)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_ingress_cidr" {
  description = "CIDR allowed for MySQL port"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_pair_name" {
  description = "EC2 key pair name to create"
  type        = string
  default     = "community-v1-key"
}

variable "public_key_path" {
  description = "Path to the local public key file (.pub) used for EC2 key pair"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
  default     = "jongju-mate-clay"
}

variable "ecr_repository_back_name" {
  description = "ECR repository name for backend image"
  type        = string
  default     = "community-back"
}

variable "ecr_repository_front_name" {
  description = "ECR repository name for frontend image"
  type        = string
  default     = "community-front"
}

variable "deploy_iam_user_name" {
  description = "IAM user name for GitHub Actions ECR deployment"
  type        = string
  default     = "community-deployer"
}

variable "app_deploy_target" {
  description = "Deploy target tag value for SSM/GitHub Actions targeting"
  type        = string
  default     = "community-app"
}

variable "monitoring_deploy_target" {
  description = "Deploy target tag value for monitoring server targeting"
  type        = string
  default     = "community-monitoring"
}

variable "mysql_deploy_target" {
  description = "Deploy target tag value for mysql server targeting"
  type        = string
  default     = "community-mysql"
}

variable "redis_deploy_target" {
  description = "Deploy target tag value for redis server targeting"
  type        = string
  default     = "community-redis"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
