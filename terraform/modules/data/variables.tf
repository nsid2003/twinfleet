variable "name_prefix" {
  description = "Préfixe de nommage des ressources (ex : twinfleet-staging)"
  type        = string
}

variable "data_subnet_ids" {
  description = "IDs des sous-réseaux privés de données (au moins deux AZ)"
  type        = list(string)
}

variable "db_sg_id" {
  description = "ID du security group appliqué à RDS"
  type        = string
}

variable "db_port" {
  description = "Port d'écoute de PostgreSQL"
  type        = number
}

variable "db_instance_class" {
  description = "Classe de l'instance RDS"
  type        = string
}

variable "db_engine_version" {
  description = "Version de PostgreSQL"
  type        = string
}

variable "db_allocated_storage" {
  description = "Stockage alloué (Go)"
  type        = number
}

variable "db_name" {
  description = "Nom de la base créée à l'initialisation"
  type        = string
}

variable "db_username" {
  description = "Nom de l'utilisateur administrateur"
  type        = string
}

variable "backup_retention_period" {
  description = "Rétention des sauvegardes automatiques (jours)"
  type        = number
}

variable "bucket_force_destroy" {
  description = "Vide automatiquement le bucket lors d'un destroy"
  type        = bool
}
