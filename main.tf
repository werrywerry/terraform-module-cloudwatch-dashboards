provider "aws" {
  region = "ap-southeast-2"
}

locals {
  api_list    = sort([for item in var.resource_list : keys(item)[0] if values(item)[0] == "api"])
  dynamo_list = sort([for item in var.resource_list : keys(item)[0] if values(item)[0] == "dynamo_db"])
  lambda_list = sort([for item in var.resource_list : keys(item)[0] if values(item)[0] == "lambda"])
  rds_list    = sort([for item in var.resource_list : keys(item)[0] if values(item)[0] == "rds"])

  lambda_duration_metrics = [
    for fn in local.lambda_list :
    ["AWS/Lambda", "Duration", "FunctionName", fn, { "region" : "ap-southeast-2" }]
  ]
  lambda_concurrent_execution_metrics = [
    for fn in local.lambda_list :
    ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", fn, { "region" : "ap-southeast-2" }]
  ]

  api_widgets = flatten([
    for idx, api in local.api_list : [
      {
        "height" : 3,
        "width" : 6,
        "y" : idx * 6,
        "x" : 0,
        "type" : "text",
        "properties" : {
          "markdown" : format("# API Metrics\n\n## %s", api)
        }
      },
      {
        "height" : 6,
        "width" : 5,
        "y" : idx * 6,
        "x" : 6,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            [
              "AWS/ApiGateway",
              "4XXError",
              "ApiName",
              api,
              {
                "region" : "ap-southeast-2"
              }
            ],
            [
              ".",
              "5XXError",
              ".",
              ".",
              {
                "region" : "ap-southeast-2"
              }
            ]
          ],
          "view" : "singleValue",
          "region" : "ap-southeast-2",
          "period" : 300,
          "stat" : "Sum"
        }
      },
      {
        "height" : 6,
        "width" : 13,
        "y" : idx * 6,
        "x" : 11,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            [
              "AWS/ApiGateway",
              "Latency",
              "ApiName",
              api,
              {
                "id" : "m1",
                "region" : "ap-southeast-2"
              }
            ],
            [
              ".",
              "IntegrationLatency",
              ".",
              ".",
              {
                "id" : "m2",
                "region" : "ap-southeast-2"
              }
            ]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-southeast-2",
          "period" : 300,
          "stat" : "Maximum",
          "yAxis" : {
            "left" : {
              "min" : 0
            },
            "right" : {
              "min" : 0
            }
          }
        }
      },
      {
        "height" : 3,
        "width" : 6,
        "y" : idx * 6 + 3,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "view" : "singleValue",
          "metrics" : [
            [
              "AWS/ApiGateway",
              "Count",
              "ApiName",
              api
            ]
          ],
          "region" : "ap-southeast-2"
        }
      }
    ]
  ])

  rds_y_coord = length(local.api_list) * 6
  rds_widgets = flatten([
    for idx, rds in local.rds_list : [
      {
        "height" : 6,
        "width" : 6,
        "y" : local.rds_y_coord + idx * 18,
        "x" : 0,
        "type" : "text",
        "properties" : {
          "markdown" : format("# RDS Metrics\n\n## %s\n\n* Total IOPS Usage (Alarms at 80% max)\n* Free Storage Space (Alarms at 10%)\n* Freeable Memory (Alarms at 20%)\n* CPU Utilization (Alarms at 80%)\n* DiskQueueDepth\n", rds)
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "y" : local.rds_y_coord + idx * 18,
        "x" : 6,
        "type" : "metric",
        "properties" : {
          "title" : "TotalIOPS",
          "annotations" : {
            "alarms" : [
              "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-IOPS"
            ]
          },
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "y" : local.rds_y_coord + idx * 18,
        "x" : 15,
        "type" : "metric",
        "properties" : {
          "title" : "CPUUtilization",
          "annotations" : {
            "alarms" : [
              "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-CPUUtilization"
            ]
          },
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
      {
        "height" : 6,
        "width" : 12,
        "y" : local.rds_y_coord + 6 + idx * 18,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            [
              {
                "expression" : "m1*1000",
                "label" : "ReadLatency",
                "id" : "e1",
                "region" : "ap-southeast-2"
              }
            ],
            [
              "AWS/RDS",
              "ReadLatency",
              "DBInstanceIdentifier",
              "staff-service-datastore",
              {
                "region" : "ap-southeast-2",
                "label" : "m1",
                "id" : "m1",
                "visible" : false
              }
            ]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-southeast-2",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "label" : "Milliseconds",
              "showUnits" : false
            },
            "right" : {
              "min" : 0
            }
          },
          "stat" : "Average",
          "title" : "ReadLatency"
        }
      },
      {
        "height" : 6,
        "width" : 12,
        "y" : local.rds_y_coord + 6 + idx * 18,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            [
              {
                "expression" : "m1*1000",
                "label" : "WriteLatency",
                "id" : "e1",
                "region" : "ap-southeast-2"
              }
            ],
            [
              "AWS/RDS",
              "WriteLatency",
              "DBInstanceIdentifier",
              "staff-service-datastore",
              {
                "region" : "ap-southeast-2",
                "label" : "m1",
                "id" : "m1",
                "visible" : false
              }
            ]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-southeast-2",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "showUnits" : false,
              "label" : "Milliseconds"
            },
            "right" : {
              "min" : 0
            }
          },
          "stat" : "Average",
          "title" : "WriteLatency"
        }
      },
      {
        "height" : 6,
        "width" : 8,
        "y" : local.rds_y_coord + 12 + idx * 18,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "title" : "FreeableMemory",
          "annotations" : {
            "alarms" : [
              "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-FreeableMemory"
            ]
          },
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
      {
        "height" : 6,
        "width" : 8,
        "y" : local.rds_y_coord + 12 + idx * 18,
        "x" : 8,
        "type" : "metric",
        "properties" : {
          "title" : "FreeStorageSpace",
          "annotations" : {
            "alarms" : [
              "arn:aws:cloudwatch:ap-southeast-2:318468042250:alarm:staff-service-datastore-FreeStorageSpace"
            ]
          },
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
      {
        "height" : 6,
        "width" : 8,
        "y" : local.rds_y_coord + 12 + idx * 18,
        "x" : 16,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            [
              "AWS/RDS",
              "DiskQueueDepth",
              "DBInstanceIdentifier",
              "staff-service-datastore",
              {
                "region" : "ap-southeast-2"
              }
            ]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-southeast-2",
          "period" : 300,
          "stat" : "Maximum",
          "yAxis" : {
            "left" : {
              "min" : 0
            },
            "right" : {
              "min" : 0
            }
          }
        }
      }
    ]
  ])

  dynamo_y_coord = local.rds_y_coord + length(local.rds_list) * 18
  dynamo_widgets = flatten([
    for idx, dynamo in local.dynamo_list : [
      {
        "type" : "metric",
        "x" : 6,
        "y" : local.dynamo_y_coord,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", "PayloadService-PayloadsStore-dev-DynamoDB", "Operation", "Query"]
          ],
          "region" : "ap-southeast-2"
        }
      },
      {
        "type" : "text",
        "x" : 0,
        "y" : local.dynamo_y_coord,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "markdown" : "# DynamoDB\n## PayloadService-PayloadsStore-dev-DynamoDB\n* SuccessfulRequestLatency\n* ConsumedReadCapacityUnits\n* ConsumedWriteCapcityUntis"
        }
      },
      {
        "type" : "metric",
        "x" : 12,
        "y" : local.dynamo_y_coord,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", "PayloadService-PayloadsStore-dev-DynamoDB"]
          ],
          "region" : "ap-southeast-2"
        }
      },
      {
        "type" : "metric",
        "x" : 18,
        "y" : local.dynamo_y_coord,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", "PayloadService-PayloadsStore-dev-DynamoDB"]
          ],
          "region" : "ap-southeast-2"
        }
      }
    ]
  ])

  lambda_y_coord = local.dynamo_y_coord + length(local.dynamo_list) * 6
  lambda_widgets = [
    {
      "height" : 6,
      "width" : 6,
      "y" : local.lambda_y_coord,
      "x" : 0,
      "type" : "text",
      "properties" : {
        "markdown" : "# Lambda Metrics\n\n* Duration\n* ConcurrentExecutions\n\n[View detailed lambda dashboard](https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#dashboards:name=StaffService-Dev-LambdaDashboard)"
      }
    },
    {
      "height" : 6,
      "width" : 9,
      "y" : local.lambda_y_coord,
      "x" : 6,
      "type" : "metric",
      "properties" : {
        "view" : "timeSeries",
        "stacked" : false,
        "metrics" : local.lambda_duration_metrics,
        "region" : "ap-southeast-2",
        "period" : 300,
        "yAxis" : {
          "left" : {
            "showUnits" : false,
            "label" : "Milliseconds",
            "min" : 0
          }
        }
      }
    },
    {
      "height" : 6,
      "width" : 9,
      "y" : local.lambda_y_coord,
      "x" : 15,
      "type" : "metric",
      "properties" : {
        "metrics" : local.lambda_concurrent_execution_metrics,
        "view" : "timeSeries",
        "stacked" : false,
        "region" : "ap-southeast-2",
        "period" : 300,
        "stat" : "Maximum",
        "yAxis" : {
          "left" : {
            "label" : "Executions",
            "showUnits" : true,
            "min" : 0
          }
        }
      }
    }
  ]

  api_rds_widgets        = concat(local.api_widgets, local.rds_widgets)
  api_rds_dynamo_widgets = concat(local.api_rds_widgets, local.dynamo_widgets)
  widgets                = concat(local.api_rds_dynamo_widgets, local.lambda_widgets)
}
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = format("%s-%s-PerformanceDashboard", var.service_name, var.env)

  dashboard_body = jsonencode(
    {
      "widgets" : local.widgets
    }
  )
}
