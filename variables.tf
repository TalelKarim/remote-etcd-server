variable "region" {
  description = "The region where the runner will be run"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_id" {
  description = "The id of the vpc"
  type        = string
  default     = "vpc-0a061c1d8965de48a"
}


variable "subnet_id" {
  description = "The id of the subnet"
  type        = string
  default     = "subnet-053a20a7d2555dc25"
}
