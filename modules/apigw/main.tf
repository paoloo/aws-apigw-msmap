/* ========================================================================= */
variable "environment"         { }
variable "app_name"            { }
/* ========================================================================= */

resource "aws_api_gateway_rest_api" "api" {
 name = "${var.app_name}-${var.environment}-gw"
 description = "Proxy to handle requests to our API"
}

/* ========================================================================= */
output "apigw_id"  { value = "${aws_api_gateway_rest_api.api.id}"               }
output "apigw_rri" { value = "${aws_api_gateway_rest_api.api.root_resource_id}" }
/* ========================================================================= */
