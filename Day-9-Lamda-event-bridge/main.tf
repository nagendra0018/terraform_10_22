# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_eventbridge_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create a ZIP file for Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda Function
resource "aws_lambda_function" "eventbridge_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "eventbridge_triggered_lambda"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 128

  environment {
    variables = {
      ENV = "production"
    }
  }

  tags = {
    Name = "EventBridge-Lambda"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.eventbridge_lambda.function_name}"
  retention_in_days = 7
}

# EventBridge Rule - Scheduled (runs every 5 minutes)
resource "aws_cloudwatch_event_rule" "scheduled_rule" {
  name                = "lambda-scheduled-rule"
  description         = "Trigger Lambda every 5 minutes"
  schedule_expression = "cron(0/5 * * * ? *)"
  # Format: cron(Minutes Hours Day-of-month Month Day-of-week Year)
  # 0/5 means: starting at minute 0, then every 5 minutes (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
  
  # Other time-based examples:
  # schedule_expression = "cron(30 10 * * ? *)"     # Once per day at 10:30 AM UTC
  # schedule_expression = "cron(0 9 ? * MON-FRI *)" # Weekdays at 9:00 AM UTC
  # schedule_expression = "rate(5 minutes)"         # Every 5 minutes (simpler syntax)
}

# EventBridge Rule - Event Pattern (triggers on EC2 state changes)
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change-rule"
  description = "Trigger Lambda on EC2 instance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running", "stopped", "terminated"]
    }
  })
}

# EventBridge Target for Scheduled Rule
resource "aws_cloudwatch_event_target" "lambda_scheduled_target" {
  rule      = aws_cloudwatch_event_rule.scheduled_rule.name
  target_id = "lambda-scheduled-target"
  arn       = aws_lambda_function.eventbridge_lambda.arn
}

# EventBridge Target for EC2 State Change Rule
resource "aws_cloudwatch_event_target" "lambda_ec2_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  target_id = "lambda-ec2-target"
  arn       = aws_lambda_function.eventbridge_lambda.arn
}

# Lambda Permission for EventBridge (Scheduled Rule)
resource "aws_lambda_permission" "allow_eventbridge_scheduled" {
  statement_id  = "AllowExecutionFromEventBridgeScheduled"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eventbridge_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_rule.arn
}

# Lambda Permission for EventBridge (EC2 Rule)
resource "aws_lambda_permission" "allow_eventbridge_ec2" {
  statement_id  = "AllowExecutionFromEventBridgeEC2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eventbridge_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change.arn
}

# Outputs
output "lambda_function_arn" {
  value       = aws_lambda_function.eventbridge_lambda.arn
  description = "ARN of the Lambda function"
}

output "lambda_function_name" {
  value       = aws_lambda_function.eventbridge_lambda.function_name
  description = "Name of the Lambda function"
}

output "scheduled_rule_arn" {
  value       = aws_cloudwatch_event_rule.scheduled_rule.arn
  description = "ARN of the scheduled EventBridge rule"
}

output "ec2_rule_arn" {
  value       = aws_cloudwatch_event_rule.ec2_state_change.arn
  description = "ARN of the EC2 state change EventBridge rule"
}
