locals {
  api_list    = [for api in var.resource_list["apis"] : api]
  dynamo_list = [for dynamo in var.resource_list["dynamos"] : dynamo]
  rds_list    = [for rds in var.resource_list["rdss"] : rds]

  lambda_duration_metrics = [
    for lambda_obj in local.lambda_list : [
      "AWS/Lambda", "Duration", "FunctionName", lambda_obj.lambda, { "region" : "ap-southeast-2" }
    ]
  ]
  lambda_concurrent_execution_metrics = [
    for lambda_obj in local.lambda_list : [
      "AWS/Lambda", "ConcurrentExecutions", "FunctionName", lambda_obj.lambda, { "region" : "ap-southeast-2" }
    ]
  ]

  api_widgets = flatten([
    for idx, api in local.api_list : [
      # API text widget
      {
        "height" : 3,
        "width" : 6,
        "y" : idx * 6,
        "x" : 0,
        "type" : "text",
        "properties" : {
          "markdown" : format("# API Metrics\n\n## %s", api.api)
        }
      },
      # API 4xx and 5xx widget
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
              api.api,
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
      # API Latency and Integration Latency widget
      {
        "height" : 6,
        "width" : 13,
        "y" : idx * 6,
        "x" : 11,
        "type" : "metric",
        "properties" : {
          "annotations" : {
            "alarms" : [
              for alarm in api.alarms :
              alarm["latency_alarm_arn"] if contains(keys(alarm), "latency_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "region" : "ap-southeast-2",
          "period" : 300,
          "stat" : "Sum"
        }
      },
      # API hit count widget
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
              api.api
            ]
          ],
          "region" : "ap-southeast-2"
        }
      }
    ]
  ])

  rds_y_coord = length(local.api_list) * 6
  rds_widgets = flatten([
    # API text widget
    for idx, rds in local.rds_list : [
      {
        "height" : 6,
        "width" : 6,
        "y" : local.rds_y_coord + idx * 18,
        "x" : 0,
        "type" : "text",
        "properties" : {
          "markdown" : format("# RDS Metrics\n\n## %s\n\n* Total IOPS Usage (Alarms at 80%% max)\n* Free Storage Space (Alarms at 10%%)\n* Freeable Memory (Alarms at 20%%)\n* CPU Utilization (Alarms at 80%%)\n* DiskQueueDepth\n", rds.rds)
        }
      },
      # API IOPS widget
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
              for alarm in rds.alarms :
              alarm["iops_alarm_arn"] if contains(keys(alarm), "iops_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
    # RDS CPU widget
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
              for alarm in rds.alarms :
              alarm["cpu_alarm_arn"] if contains(keys(alarm), "cpu_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
    # RDS Read Latency widget
      {
        "height" : 6,
        "width" : 12,
        "y" : local.rds_y_coord + 6 + idx * 18,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "title" : "ReadLatency",
          "annotations" : {
            "alarms" : [
              for alarm in rds.alarms :
              alarm["read_alarm_arn"] if contains(keys(alarm), "read_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
    # RDS Write Latency widget
      {
        "height" : 6,
        "width" : 12,
        "y" : local.rds_y_coord + 6 + idx * 18,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "title" : "WriteLatency",
          "annotations" : {
            "alarms" : [
              for alarm in rds.alarms :
              alarm["write_alarm_arn"] if contains(keys(alarm), "write_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
    # RDS Memory widget
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
              for alarm in rds.alarms :
              alarm["memory_alarm_arn"] if contains(keys(alarm), "memory_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
    # RDS Storage widget
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
              for alarm in rds.alarms :
              alarm["storage_alarm_arn"] if contains(keys(alarm), "storage_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "stacked" : false,
          "type" : "chart"
        }
      },
    # RDS Disk Queue widget
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
              rds.rds,
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
    # Dynamo Text widget
      {
        "type" : "text",
        "x" : 0,
        "y" : local.dynamo_y_coord,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "markdown" : format("# DynamoDB\n## %s\n* SuccessfulRequestLatency\n* ConsumedReadCapacityUnits\n* ConsumedWriteCapcityUntis", dynamo.dynamo)
        }
      },
    # Dynamo SuccessRequest widget
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
            ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", dynamo.dynamo, "Operation", "Query"]
          ],
          "region" : "ap-southeast-2"
        }
      },
    # Dynamo Read Units widget
      {
        "type" : "metric",
        "x" : 12,
        "y" : local.dynamo_y_coord,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "title" : "ConsumedReadCapacityUnits"
          "view" : "timeSeries",
          "stacked" : false,
          "annotations" : {
            "alarms" : [
              for alarm in dynamo.alarms :
              alarm["read_alarm_arn"] if contains(keys(alarm), "read_alarm_arn")
            ],
          }
          "region" : "ap-southeast-2"
        }
      },
    # Dynamo Write Units widget
      {
        "type" : "metric",
        "x" : 18,
        "y" : local.dynamo_y_coord,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "title" : "ConsumedWriteCapacityUnits"
          "annotations" : {
            "alarms" : [
              for alarm in dynamo.alarms :
              alarm["write_alarm_arn"] if contains(keys(alarm), "write_alarm_arn")
            ],
          }
          "region" : "ap-southeast-2"
        }
      }
    ]
  ])

  lambda_y_coord = local.dynamo_y_coord + length(local.dynamo_list) * 6
  lambda_widgets_text = length(local.lambda_list) > 0 ? [
    # Lambda Text widget
    {
      "height" : 6,
      "width" : 6,
      "y" : local.lambda_y_coord,
      "x" : 0,
      "type" : "text",
      "properties" : {
        "markdown" : format("# Lambda Metrics\n\n* Duration\n* ConcurrentExecutions\n\n[View detailed lambda dashboard](%s)", local.lambda_dashboard_url)
      }
    }
  ] : []
  # Lambda Durations widget
  lambda_widgets_metric_1 = length(local.lambda_list) > 0 ? [
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
    }
  ] : []
  # Lambda Executions widget
  lambda_widgets_metric_2 = length(local.lambda_list) > 0 ? [
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
  ] : []

  lambda_widgets = concat(
    local.lambda_widgets_text,
    local.lambda_widgets_metric_1,
    local.lambda_widgets_metric_2
  )

performance_widgets = concat(
  local.api_widgets, 
  local.rds_widgets, 
  local.dynamo_widgets, 
  local.lambda_widgets
  )
}
