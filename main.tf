/* ========================================================================= */
variable "region"           { default     = "us-west-2"                      }
variable "environment"      { default     = "stg"                            }
variable "app_name"         { default     = "paolo"                          }
variable "base_domain"      { default     = "paolo.zone"                   }
/* ========================================================================= */
provider "aws" {
  alias                   = "certificate"
  region                  = "us-east-1"
  profile                 = "aws-test"
  shared_credentials_file = "$HOME/.aws/credentials"
}
/* ========================================================================= */

provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "rally"
  region                  = "${var.region}"
}

module "hostname" {
  source                  = "./modules/route53"
  app_name                = "${var.app_name}"
  environment             = "${var.environment}"
  base_domain             = "${var.base_domain}"
}

module "agw" {
  source                  = "./modules/apigw"
  app_name                = "${var.app_name}"
  environment             = "${var.environment}"
}

module "endp1" {
  source                  = "./modules/apigw/struct"
  apigw_id                = "${module.agw.apigw_id}"
  apigw_rri               = "${module.agw.apigw_rri}"
  endpoint                = "alpha"
  target                  = "https://webhook.site/dc7609e7-8e10-43b9-9cbd-02793f2b25ab"
}

module "endp2" {
  source                  = "./modules/apigw/struct"
  apigw_id                = "${module.agw.apigw_id}"
  apigw_rri               = "${module.agw.apigw_rri}"
  endpoint                = "beta"
  target                  = "https://webhook.site/8c1ed8a5-87db-437b-87fb-4395cf05831d"
}

module "setitup" {
  source                  = "./modules/apigw/deploy"
  apigw_id                = "${module.agw.apigw_id}"
  domain_name             = "${module.hostname.domain_name}"
  extra_vars              = {"1"="${module.endp1.endpoint}",
                             "2"="${module.endp2.endpoint}"}
}
