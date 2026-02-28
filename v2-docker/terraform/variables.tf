variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile name. Set null to use default credential chain."
  type        = string
  default     = null
  nullable    = true
}

variable "project_name" {
  description = "Project prefix used in resource names and tags"
  type        = string
  default     = "community-v2-docker"
}

variable "project_tag" {
  description = "Project tag value used for operational targeting"
  type        = string
  default     = "community"
}

variable "environment" {
  description = "Environment name used in tags and bucket naming (e.g. dev, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "s3_bucket_base_name" {
  description = "Base bucket name. Final name becomes <base>-<environment> unless override is set."
  type        = string
  default     = "community-v2-docker-assets"
}

variable "s3_bucket_name_override" {
  description = "Optional full bucket name override (must be globally unique)."
  type        = string
  default     = null
  nullable    = true
}

variable "bucket_force_destroy" {
  description = "Allow deleting non-empty bucket. Keep false for prod."
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
