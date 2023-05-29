provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_cloudwatch_dashboard" "performance" {
  dashboard_name = format("%s-%s-PerformanceDashboard", var.service_name, var.env)

  dashboard_body = jsonencode(
    {
      "widgets" : local.performance_widgets
    }
  )
}

resource "aws_cloudwatch_dashboard" "lambda" {
  count = length(local.lambda_detail_widgets) > 0 ? 1 : 0

  dashboard_name = format("%s-%s-LambdaDashboard", var.service_name, var.env)

  dashboard_body = jsonencode({
    "widgets": local.lambda_detail_widgets
  })
}
