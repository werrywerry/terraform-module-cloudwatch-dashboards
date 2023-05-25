variable "dashboard_name" {
  type    = string
  default = "terraform-test-dashboard"
}

variable "service_name" {
  type    = string
  default = "terraform-test-dashboard"
}

variable "resource_list" {
  type = list(map(string))
  default = [
    {
      "staff-service-v3" = "api"
    },
    {
      "staff-service-datastore" = "rds"
    },
    {
      "staff-personal-location-change-event-processor" = "lambda"
    },
    {
      "staff-personal-change-event-processor-lambda" = "lambda"
    },
    {
      "staff-service-staffassignment-request-handler-lambda" = "lambda"
    },
    {
      "staff-service-staffpersonal-request-handler-lambda" = "lambda"
    },
    {
      "staff-change-event-notification-lambda" = "lambda"
    },
    {
      "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-IOPS" = "rds_alarm"
    },
    {
      "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-CPUUtilization" = "rds_alarm"
    },
    {
      "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-FreeableMemory" = "rds_alarm"
    },
    {
      "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-FreeStorageSpace" = "rds_alarm"
    }
  ]
}
