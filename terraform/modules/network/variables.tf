variable "name_prefix" {
  description = "Préfixe de nommage des ressources (ex : twinfleet-staging)"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr doit être un bloc CIDR valide."
  }
}

variable "azs" {
  description = "Zones de disponibilité (une par sous-réseau de chaque niveau)"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Au moins deux zones de disponibilité sont nécessaires (exigence de l'ALB)."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR des sous-réseaux publics, dans l'ordre de var.azs"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "Il faut exactement un sous-réseau public par zone de disponibilité."
  }
}

variable "app_subnet_cidrs" {
  description = "CIDR des sous-réseaux privés applicatifs, dans l'ordre de var.azs"
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_cidrs) == length(var.azs)
    error_message = "Il faut exactement un sous-réseau applicatif par zone de disponibilité."
  }
}

variable "data_subnet_cidrs" {
  description = "CIDR des sous-réseaux privés de données, dans l'ordre de var.azs"
  type        = list(string)

  validation {
    condition     = length(var.data_subnet_cidrs) == length(var.azs)
    error_message = "Il faut exactement un sous-réseau de données par zone de disponibilité."
  }
}

variable "app_port" {
  description = "Port sur lequel l'ALB joint les instances applicatives"
  type        = number
}

variable "db_port" {
  description = "Port de la base de données"
  type        = number
}
