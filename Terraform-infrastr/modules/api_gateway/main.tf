resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = var.protocol_type
  description   = var.description
  tags          = var.tags
}

resource "aws_apigatewayv2_integration" "this" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = var.integration_type
  integration_uri        = var.integration_uri
  integration_method     = var.integration_method
  connection_type        = var.connection_type
  payload_format_version = var.payload_format_version
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true
}
