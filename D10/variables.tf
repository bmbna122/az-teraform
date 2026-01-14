variable "environment" {
  type        = string
  description = "The environment for all resources"
  default     = "stag"
}

variable "account_names" {
    type        = list(string)
    description = "The names for storage accounts"
    default     = ["financestorageacct11", "financestorageacct102"]
}