variable "modname" {}
variable "delivery_channel_s3_bucket_name" {}
variable "aws_account" {}
variable "inactive-user-path" {}
variable "unused-keys-path" {}

variable "naming_prefix" {
  type    = "string"
  default = "aws-config"
}
