variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "Project ALPHA Resources"
}

variable "default_tags" {
  type        = map(string)
  description = "A map of default tags to apply to all resources"
  default     = {
    # Default tags
    company    = "TechCorp"
    managed_by = "terraform"

  }
}

variable "environment_tags" {
  type        = map(string)
  description = "A map of environment specific tags to apply to all resources"
  default     = {

# Environment tags

    environment  = "production"
    cost_center = "cc-123"
  }
}

variable "storage_account_name" {
  type        = string
  description = "The names for storage accounts"
  default     = "techtutoRIal with !PIyushthis should be formatted"
}

variable "allowed_ports" {
    type = string
    default = "80,443,3306"
}

variable "environment" {
  type        = string
  description = "the env type"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of 'dev', 'staging', or 'prod'."
  }
}

# variable "environments" {
#   type = map(object({
#     instance_size = string
#     redundancy    = string
#   }))
#   description = "Map of environment names to their descriptions"
#   default = {
#     dev = {
#         instance_size = "small"
#         redundancy    = "low"
#     }
#     prod = {
#         instance_size = "large"
#         redundancy    = "high"
#     }
#     staging = {
#         instance_size = "medium"
#         redundancy    = "medium"
# }
#   }
# }
variable "vm_sizes" {
  type        = map(string)
  description = "Map of environment names to VM sizes"
  default     = {
    dev     = "Standard_B1s",
    staging = "Standard_B2s",
    prod    = "Standard_D2s_v3"
  }
}

variable "vm_size" {
  type = string
  default = "Standard_B1s"
  validation {
    condition = length(var.vm_size) >=2 && length(var.vm_size) <=20
    error_message = "VM size must be between 2 and 20 characters long."
  }
  validation {
    condition     = strcontains(lower(var.vm_size), "standard_")
    error_message = "VM size must start with 'Standard_'."
  }
}

variable "backup" {
  default = "test_backup"
  type = string
  validation {
    condition = endswith(var.backup, "_backup")
    error_message = "Backup name must end with '_backup'."
  }
}

variable "credentials" {
  default = "xyz123"
  type =  string
  sensitive = true

}