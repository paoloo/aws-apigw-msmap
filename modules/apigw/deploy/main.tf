/* ========================================================================= */
variable "apigw_id"    {}
variable "domain_name" {}
variable "extra_vars"  { type = "map" }
/* ========================================================================= */

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = "${var.apigw_id}"
  stage_name  = "live"
  variables = "${var.extra_vars}"
}

/* ========================================================================= */
resource "aws_api_gateway_base_path_mapping" "test" {
  api_id      = "${var.apigw_id}"
  stage_name  = "${aws_api_gateway_deployment.api.stage_name}"
  domain_name = "${var.domain_name}"
}
/* ========================================================================= */
