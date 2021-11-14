variable "domain" {
  description = "Domain name for certificate creation. Domain creation isn't managed by this module"
  default     = "yourdomain.com"
}

variable "hosted_zone_id" {
  description = "Hosted zone ID of your domain in Route53. This is used to validate the certificate"
  default     = "YOUR-HOSTED-ZONE"
}

variable "image_address" {
  description = "Address of the docker image you with to deploy to the ECS cluster"
  default     = "yourRepo/yourContainer:yourVersion"
}


# Tags
# I chose not to use tagging in this example, but you can add tags to your resources by adding this variable to your resource definition
# Note that in AWS not all resources support tagging, so check AWS documentation for your resource type to see if it supports it
variable "tags" {
  description = "Specifies object tags key and value."
  default = {
    "purpose"       = "techtest"
    "company"       = "kantox"
    "creator"       = "pablojabase"
    "terraform-id"  = "helloworld-app"
  }
}
