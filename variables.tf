variable "service_name" {
  type        = string
  description = "System or service name for which this dashboard is being created eg StaffService"
  default     = "StaffServiceTest"
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
  default = {
    "lambdas" : [
      {
        "lambda" : "staff-personal-change-event-processor-lambda",
        "alarms" : [
          { "error_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-staff-personal-change-event-processor-lambda-Errors" },
          { "duration_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-staff-personal-change-event-processor-lambda-Duration" },
          { "throttles_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-staff-personal-change-event-processor-lambda-Throttles" },
          { "executions_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-staff-personal-change-event-processor-lambda-ConcurrentExecutions" }
        ]
      }
    ],
    "rdss" : [
      {
        "rds" : "staff-service-datastore",
        "alarms" : [
          { "iops_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-IOPS" },
          { "cpu_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-CPUUtilization" },
          { "read_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-ReadLatency" },
          { "write_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-WriteLatency" },
          { "memory_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-FreeableMemory" },
          { "storage_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-FreeStorageSpace" }
      ] }
    ],
    "apis" : [
      {
        "api" : "staff-service-v3",
        "alarms" : [
          { "latency_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-api-gateway-Latency" },
          { "integrationlatency_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-api-gateway-IntegrationLatency" }
        ]
      }
    ],
    "dynamos" : [
      {
        "dynamo" : "CapabilityDemo-AwsXray",
        "alarms" : [
          { "read_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:CapabilityDemo-AwsXray-ConsumedReadCapacityUnits" },
          { "write_alarm_arn" : "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:CapabilityDemo-AwsXray-ConsumedWriteCapacityUnits" }
        ]
      }
    ]
  }
}

variable "env" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}
