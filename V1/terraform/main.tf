locals {
  default_tags = merge(var.common_tags, {
    Project     = var.project_tag
    Environment = var.environment
  })
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-vpc"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-public-subnet-a"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for app instance"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "app"
  })

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group_rule" "app_http" {
  type              = "ingress"
  description       = "HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.app_ingress_cidr]
}

resource "aws_security_group_rule" "app_https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.app_ingress_cidr]
}

resource "aws_security_group_rule" "app_service" {
  type              = "ingress"
  description       = "App service"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.app_ingress_cidr]
}

resource "aws_security_group_rule" "app_ssh" {
  type              = "ingress"
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.ssh_ingress_cidr]
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "monitoring" {
  name        = "${var.project_name}-monitoring-sg"
  description = "Security group for monitoring instance"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "monitoring"
  })

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group_rule" "monitoring_ssh" {
  type              = "ingress"
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.monitoring.id
  cidr_blocks       = [var.ssh_ingress_cidr]
}

resource "aws_security_group_rule" "monitoring_grafana" {
  type              = "ingress"
  description       = "Grafana"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.monitoring.id
  cidr_blocks       = [var.monitoring_ingress_cidr]
}

resource "aws_security_group_rule" "monitoring_prometheus" {
  type              = "ingress"
  description       = "Prometheus"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  security_group_id = aws_security_group.monitoring.id
  cidr_blocks       = [var.monitoring_ingress_cidr]
}

resource "aws_security_group_rule" "monitoring_egress_all" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.monitoring.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for db instance"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "db"
  })

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group_rule" "db_ssh" {
  type              = "ingress"
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = [var.ssh_ingress_cidr]
}

resource "aws_security_group_rule" "db_mysql_from_admin" {
  type              = "ingress"
  description       = "MySQL from admin IP"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = [var.db_ingress_cidr]
}

resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "db_mysql_from_app_ec2" {
  type              = "ingress"
  description       = "Allow MySQL from app EC2 private IP"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = [format("%s/32", aws_instance.app.private_ip)]
}

resource "aws_security_group_rule" "db_redis_from_app_ec2" {
  type              = "ingress"
  description       = "Allow Redis from app EC2 private IP"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = [format("%s/32", aws_instance.app.private_ip)]
}

resource "aws_security_group_rule" "app_node_exporter_from_monitoring" {
  type                     = "ingress"
  description              = "Allow node exporter from monitoring instance"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "app_cadvisor_from_monitoring" {
  type                     = "ingress"
  description              = "Allow cadvisor from monitoring instance"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "monitoring_loki_from_app" {
  type                     = "ingress"
  description              = "Allow Loki ingest from app instance"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "monitoring_prometheus_from_app" {
  type                     = "ingress"
  description              = "Allow Prometheus remote write from app instance"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "monitoring_prometheus_from_db" {
  type                     = "ingress"
  description              = "Allow Prometheus remote write from db instance"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring.id
  source_security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "monitoring_loki_from_db" {
  type                     = "ingress"
  description              = "Allow Loki ingest from db instance"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring.id
  source_security_group_id = aws_security_group.db.id
}

resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)

  tags = merge(local.default_tags, {
    Name = var.key_pair_name
  })
}

data "aws_iam_policy_document" "app_ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_ec2_role" {
  name               = "${var.project_name}-app-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.app_ec2_assume_role.json

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-app-ec2-role"
  })
}

data "aws_iam_policy_document" "app_s3_access" {
  statement {
    sid = "AllowListBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.main.arn]
  }

  statement {
    sid = "AllowObjectRW"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.main.arn}/*"]
  }
}

resource "aws_iam_policy" "app_s3_access" {
  name   = "${var.project_name}-app-s3-access"
  policy = data.aws_iam_policy_document.app_s3_access.json

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-app-s3-access"
  })
}

resource "aws_iam_role_policy_attachment" "app_s3_access" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = aws_iam_policy.app_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "app_ecr_readonly" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "app_ssm_core" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app_ec2_role.name
}

resource "aws_instance" "app" {
  ami                         = var.app_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = merge(local.default_tags, {
    Name         = "app"
    Role         = "app"
    DeployTarget = var.app_deploy_target
  })
}

resource "aws_eip" "app" {
  domain = "vpc"

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-app-eip"
    Role = "app"
  })
}

resource "aws_eip_association" "app" {
  instance_id   = aws_instance.app.id
  allocation_id = aws_eip.app.id
}

resource "aws_instance" "monitoring" {
  ami                         = var.monitoring_ami_id
  instance_type               = var.monitoring_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = merge(local.default_tags, {
    Name         = "monitoring"
    Role         = "monitoring"
    DeployTarget = var.monitoring_deploy_target
  })
}

resource "aws_instance" "mysql" {
  ami                         = var.mysql_ami_id
  instance_type               = var.mysql_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.db.id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = merge(local.default_tags, {
    Name         = "mysql"
    Role         = "mysql"
    DeployTarget = var.mysql_deploy_target
  })
}

resource "aws_instance" "redis" {
  ami                         = var.redis_ami_id
  instance_type               = var.redis_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.db.id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = merge(local.default_tags, {
    Name         = "redis"
    Role         = "redis"
    DeployTarget = var.redis_deploy_target
  })
}

resource "aws_s3_bucket" "main" {
  bucket = var.s3_bucket_name

  tags = merge(local.default_tags, {
    Name = var.s3_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ecr_repository" "community_back" {
  name                 = var.ecr_repository_back_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.default_tags, {
    Name = var.ecr_repository_back_name
  })
}

resource "aws_ecr_repository" "community_front" {
  name                 = var.ecr_repository_front_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.default_tags, {
    Name = var.ecr_repository_front_name
  })
}

resource "aws_ecr_lifecycle_policy" "community_back" {
  repository = aws_ecr_repository.community_back.name
  policy     = file("${path.module}/ecr-lifecycle-policy.json")
}

resource "aws_ecr_lifecycle_policy" "community_front" {
  repository = aws_ecr_repository.community_front.name
  policy     = file("${path.module}/ecr-lifecycle-policy.json")
}

resource "aws_iam_user" "deploy" {
  name = var.deploy_iam_user_name

  tags = merge(local.default_tags, {
    Name = var.deploy_iam_user_name
  })
}

data "aws_iam_policy_document" "deploy_ecr_push" {
  statement {
    sid = "AllowEcrAuthToken"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowPushToRepos"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]
    resources = [
      aws_ecr_repository.community_back.arn,
      aws_ecr_repository.community_front.arn
    ]
  }

  statement {
    sid = "AllowSsmSendCommand"
    actions = [
      "ssm:SendCommand"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowSsmReadCommandResult"
    actions = [
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
      "ssm:ListCommands"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowEc2DescribeInstances"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "deploy_ecr_push" {
  name   = "${var.project_name}-deploy-ecr-push"
  policy = data.aws_iam_policy_document.deploy_ecr_push.json

  tags = merge(local.default_tags, {
    Name = "${var.project_name}-deploy-ecr-push"
  })
}

resource "aws_iam_user_policy_attachment" "deploy_ecr_push" {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.deploy_ecr_push.arn
}

resource "aws_iam_access_key" "deploy" {
  user = aws_iam_user.deploy.name
}
