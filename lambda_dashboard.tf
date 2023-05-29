provider "aws" {
  region = "ap-southeast-2"
}

locals {
  widget_height = 8
  lambda_list = sort([for item in var.resource_list : keys(item)[0] if values(item)[0] == "lambda"])

  widgets = flatten([
    for idx, lambda_name in local.lambda_list : [
      {
        "height": 2,
        "width": 6,
        "y": idx * local.widget_height,
        "x": 0,
        "type": "text",
        "properties": {
          "markdown": format("## %s \n", lambda_name)
        }
      },
      {
        "height": 3,
        "width": 6,
        "y": idx * local.widget_height + 2,
        "x": 0,
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/Lambda", "Errors", "FunctionName", lambda_name, {"region": "ap-southeast-2"}]
          ],
          "view": "singleValue",
          "stacked": false,
          "region": "ap-southeast-2",
          "period": 300,
          "stat": "Sum"
        }
      },
      {
        "height": 3,
        "width": 6,
        "y": idx * local.widget_height + 5,
        "x": 0,
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/Lambda", "Throttles", "FunctionName", lambda_name, {"region": "ap-southeast-2"}]
          ],
          "sparkline": false,
          "view": "singleValue",
          "region": "ap-southeast-2",
          "stat": "Sum",
          "period": 300
        }
      },
      {
        "height": 8,
        "width": 9,
        "y": idx * local.widget_height,
        "x": 6,
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/Lambda", "Duration", "FunctionName", lambda_name, {"stat": "Average", "region": "ap-southeast-2"}]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "ap-southeast-2",
          "period": 300,
          "yAxis": {
            "left": {
              "min": 0
            }
          }
        }
      },
      {
        "height": 8,
        "width": 9,
        "y": idx * local.widget_height,
        "x": 15,
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/Lambda", "Invocations", "FunctionName", lambda_name, {"region": "ap-southeast-2"}]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "ap-southeast-2",
          "yAxis": {
            "left": {
              "min": 0,
              "showUnits": true
            }
          },
          "period": 300,
          "stat": "Maximum"
        }
      }
    ]
  ])
}

resource "aws_cloudwatch_dashboard" "lambda" {
  dashboard_name = format("%s-%s-LambdaDashboard", var.service_name, var.env)

  dashboard_body = jsonencode({
    "widgets": local.widgets
  })
}
