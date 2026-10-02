variable "name_prefix" {
  description = "Préfixe de nommage des ressources (ex : twinfleet-staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Sous-réseaux publics où est placé l'ALB"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Sous-réseaux privés où l'ASG lance les instances"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group de l'ALB"
  type        = string
}

variable "app_sg_id" {
  description = "Security group des instances applicatives"
  type        = string
}

variable "app_port" {
  description = "Port HTTP des instances"
  type        = number
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
}

variable "asg_min_size" {
  description = "Nombre minimal d'instances"
  type        = number
}

variable "asg_max_size" {
  description = "Nombre maximal d'instances"
  type        = number

  validation {
    condition     = var.asg_max_size >= var.asg_min_size
    error_message = "asg_max_size doit être supérieur ou égal à asg_min_size."
  }
}

variable "asg_desired_capacity" {
  description = "Nombre d'instances souhaité"
  type        = number

  validation {
    condition     = var.asg_desired_capacity >= var.asg_min_size && var.asg_desired_capacity <= var.asg_max_size
    error_message = "asg_desired_capacity doit être compris entre asg_min_size et asg_max_size."
  }
}

variable "health_check_path" {
  description = "Chemin HTTP du health check du Target Group"
  type        = string
}

variable "ami_ssm_parameter" {
  description = "Paramètre SSM public donnant la dernière AMI Amazon Linux 2023"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "instance_tags" {
  description = "Tags propagés aux instances lancées par l'ASG (ciblage Ansible)"
  type        = map(string)
}
