variable "name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "api-gateway"
}

variable "description" {
  description = "Description for the API Gateway"
  type        = string
  default     = "HTTP API Gateway"
}

variable "protocol_type" {
  description = "Protocol type for the API Gateway"
  type        = string
  default     = "HTTP"
}

variable "route_key" {
  description = "Route key for the API Gateway route"
  type        = string
  default     = "$default"
}

variable "integration_type" {
  description = "Integration type for API Gateway"
  type        = string
  default     = "HTTP_PROXY"
}

variable "integration_uri" {
  description = "Integration URI for the API Gateway"
  type        = string
}

variable "integration_method" {
  description = "HTTP method used for the integration"
  type        = string
  default     = "ANY"
}

variable "connection_type" {
  description = "Connection type for API Gateway integration"
  type        = string
  default     = "INTERNET"
}

variable "payload_format_version" {
  description = "Payload format version for API Gateway integration"
  type        = string
  default     = "2.0"
}

variable "stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "$default"
}

variable "tags" {
  description = "Tags for API Gateway resources"
  type        = map(string)
  default     = {}
}
