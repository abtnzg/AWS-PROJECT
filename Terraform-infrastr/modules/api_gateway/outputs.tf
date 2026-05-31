output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "stage_name" {
  description = "API Gateway stage name"
  value       = aws_apigatewayv2_stage.default.name
}

output "integration_id" {
  description = "API Gateway integration ID"
  value       = aws_apigatewayv2_integration.this.id
}
