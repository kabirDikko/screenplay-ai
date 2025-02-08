resource "aws_lambda_function" "heic_converter" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "heic-to-jpeg-converter"
  role            = aws_iam_role.lambda_role.arn
  handler         = "main.handler"
  runtime         = "python3.9"
  timeout         = 300  # 5 minutes
  memory_size     = 512

  environment {
    variables = {
      SOURCE_BUCKET = aws_s3_bucket.forex_kb.id
    }
  }

  layers = [aws_lambda_layer_version.pillow_layer.arn]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/heic_converter"
  output_path = "${path.module}/lambda/heic_converter.zip"
}

# Create Lambda Layer for dependencies
resource "aws_lambda_layer_version" "pillow_layer" {
  filename            = "${path.module}/lambda/layers/pillow_layer.zip"
  layer_name          = "pillow-heif-layer"
  compatible_runtimes = ["python3.9"]
  description         = "Layer containing Pillow and pillow-heif libraries"
} 