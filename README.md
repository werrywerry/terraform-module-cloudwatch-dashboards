Module: Lambda Layer
Module prebuilt to automate the deployment of aws dashboards

Requirements
Terraform version: 0.13.+

How to use

module "xxx-service-dashboard-module" {
  source = "git::https://bitbucket.det.nsw.edu.au/scm/entint/terraform-module-service-dashboard.git?ref=feature/initial"

  env = "Dev"

  service_name   = "StaffServiceTest"
  
  resource_list  = [
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
