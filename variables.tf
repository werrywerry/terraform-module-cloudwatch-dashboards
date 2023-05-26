variable "service_name" {
  type    = string
  description = "System or service name for which this dashboard is being created eg StaffService"
}

variable "resource_list" {
  type = list(map(string))
  description = "Key value pairs of AWS resource name and AWS resource type for which dashboard widgets should be created"
}

variable "env" {
  type = string
  description = "Deployment environment"
}
