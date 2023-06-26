
locals {
  widget_height = 8
  lambda_list   = [for lambda in var.resource_list["lambdas"] : lambda]

  lambda_detail_widgets = flatten([
    for idx, lambda_obj in local.lambda_list : [
    # Lambda Text widget
      {
        "height" : 2,
        "width" : 6,
        "y" : idx * local.widget_height,
        "x" : 0,
        "type" : "text",
        "properties" : {
          "markdown" : format("## %s \n", lambda_obj.lambda)
        }
      },
    # Lambda Errors widget
      {
        "height" : 3,
        "width" : 6,
        "y" : idx * local.widget_height + 2,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Errors", "FunctionName", lambda_obj.lambda, { "region" : "ap-southeast-2" }]
          ],
          "view" : "singleValue",
          "stacked" : false,
          "region" : "ap-southeast-2",
          "period" : 300,
          "stat" : "Sum"
        }
      },
    # Lambda Throttles widget
      {
        "height" : 3,
        "width" : 6,
        "y" : idx * local.widget_height + 5,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Throttles", "FunctionName", lambda_obj.lambda, { "region" : "ap-southeast-2" }]
          ],
          "sparkline" : false,
          "view" : "singleValue",
          "region" : "ap-southeast-2",
          "stat" : "Sum",
          "period" : 300
        }
      },
    # Lambda Duration widget
      {
        "height" : 8,
        "width" : 9,
        "y" : idx * local.widget_height,
        "x" : 6,
        "type" : "metric",
        "properties" : {
          "title" : "Duration"
          "annotations" : {
            "alarms" : [
              for alarm in lambda_obj.alarms :
              alarm["duration_alarm_arn"] if contains(keys(alarm), "duration_alarm_arn")
            ]
          }
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-southeast-2",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "min" : 0
            }
          }
        }
      },
# Lambda Success-Rate widget
{
  "height" : 8,
  "width" : 9,
  "y" : idx * local.widget_height,
  "x" : 15,
  "type" : "metric",
  "properties" : {
    "title" : "Success Rate",
    "annotations" : {
      "alarms" : [
        for alarm in lambda_obj.alarms :
        alarm["success_rate_alarm_arn"] if contains(keys(alarm), "success_rate_alarm_arn")
      ]
    },
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-southeast-2",
          "yAxis" : {
            "left" : {
              "min" : 0,
              "showUnits" : true
            }
          },
          "period" : 300,
          "stat" : "Maximum"
        }
      }
    ]
  ])
  lambda_dashboard_url = format("https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#dashboards:name=%s-%s-LambdaDashboard)", var.service_name, var.env)
}

