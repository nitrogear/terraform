vpc terraform module
===========

A terraform module to create AWS Config rules to check for unused accounts and keys.

Pre-requisites
----------------------
1. You need to have AWS Config configure. Just open the [link](https://eu-central-1.console.aws.amazon.com/config/home) below and follow Getting started instructions:

2. Zip Python files to archives iam-inactive-user.zip and iam-unused-keys.zip respectively

Module Input Variables
----------------------

- `aws_account` your AWS account ID
- `delivery_channel_s3_bucket_name` S3 bucket name which is set as delivery channel in AWS Config settings

Usage
-----

```hcl
module "rules-unused-credentials" {
  source = "github.com/nitrogear/terraform/tf_aws_config_unused_credentials"
  modname   = "tf_aws_config_unused_credentials"
  aws_account = "<AWS Account ID>"
  delivery_channel_s3_bucket_name = "<S3 bucket for AWS Config>"
  inactive-user-path = "iam-inactive-user.zip"
  unused-keys-path = "iam-unused-keys.zip"
}
```

Outputs
=======

none

Authors
=======

Originally created and maintained by [Oleksii Grinko](https://github.com/nitrogear)

License
=======

Apache 2 Licensed. See LICENSE for full details.