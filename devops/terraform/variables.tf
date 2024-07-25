variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "app_name" {
  description = "Application name"
  default     = "my-nodejs-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "List of subnet IDs for the ECS service and autoscaling group"
  type        = list(string)
}


variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "github_repo" {
  description = "GitHub repository URL"
}

variable "github_branch" {
  description = "GitHub branch"
  default     = "main"
}

variable "github_connection_arn" {
  description = "The ARN of the GitHub connection"
}
