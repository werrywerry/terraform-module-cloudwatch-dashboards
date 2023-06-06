variable "env" {
  type        = string
  description = "Deployment environment"
}

variable "service_name" {
  type        = string
  description = "System or service name for which this dashboard is being created eg StaffService"
}

variable "resource_list" {
  description = "List of AWS resources and their required alarm ARNs"
  type = object({
    apis = list(object({
      api    = string
      alarms = list(map(string))
    }))
    dynamos = list(object({
      dynamo = string
      alarms = list(map(string))
    }))
    lambdas = list(object({
      lambda = string
      alarms = list(map(string))
    }))
    rdss = list(object({
      rds    = string
      alarms = list(map(string))
    }))
  })
}