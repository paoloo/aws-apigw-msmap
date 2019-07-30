/* ========================================================================= */
variable "target"           { }
variable "endpoint"         { }
variable "apigw_id"         { }
variable "apigw_rri"        { }
/* ========================================================================= */

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${var.apigw_id}"
  parent_id   = "${var.apigw_rri}"
  path_part   = "${var.endpoint}"
}

resource "aws_api_gateway_method" "method_resource" {
  rest_api_id   = "${var.apigw_id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integration_resource" {
  rest_api_id = "${var.apigw_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method_resource.http_method}"
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "${var.target}/"
  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method_response" "response_method_resource" {
  rest_api_id = "${var.apigw_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_integration.integration_resource.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${var.apigw_id}"
  parent_id   = "${aws_api_gateway_resource.resource.id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method_proxy" {
  rest_api_id   = "${var.apigw_id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integration_proxy" {
  rest_api_id = "${var.apigw_id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.method_proxy.http_method}"
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "${var.target}/{proxy}"
  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method_response" "response_method_proxy" {
  rest_api_id = "${var.apigw_id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_integration.integration_proxy.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

output "endpoint" { value = "${aws_api_gateway_integration.integration_resource.uri}" }
