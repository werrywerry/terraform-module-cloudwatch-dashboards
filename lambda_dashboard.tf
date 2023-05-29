
locals {
  widget_height = 8
  lambda_list = sort([for item in var.resource_list : keys(item)[0] if values(item)[0] == "lambda"])

  lambda_detail_widgets = flatten([
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
  lambda_dashboard_url = format("https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#dashboards:name=%s-%s-LambdaDashboard)", format("# Lambda Metrics\n\n* Duration\n* ConcurrentExecutions\n\n[View detailed lambda dashboard](https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#dashboards:name=%s-%s-LambdaDashboard)", var.service_name, vat.env))
}

