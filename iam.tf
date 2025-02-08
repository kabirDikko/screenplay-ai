resource "aws_iam_role" "knowledge_base_role" {
  name               = "knowledge-base-role"
  assume_role_policy = data.aws_iam_policy_document.knowledge_base_role_policy.json
}

data "aws_iam_policy_document" "knowledge_base_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

data "aws_bedrock_foundation_model" "model" {
  model_id = var.model_id
}

resource "aws_iam_role_policy" "knowledge_base_role_policy" {
  name   = "knowledge-base-role-policy"
  role   = aws_iam_role.knowledge_base_role.name
  policy = data.aws_iam_policy_document.knowledge_base_permissions.json
}

data "aws_iam_policy_document" "knowledge_base_permissions" {
  statement {
    actions   = ["bedrock:InvokeModel"]
    effect    = "Allow"
    resources = [data.aws_bedrock_foundation_model.model.model_arn]
  }

  statement {
    sid       = "S3ListBucketStatement"
    actions   = ["s3:ListBucket"]
    effect    = "Allow"
    resources = [aws_s3_bucket.forex_kb.arn]
  }

  statement {
    sid       = "S3GetObjectStatement"
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.forex_kb.arn}/*"]
  }

  statement {
    sid       = "S3PutObjectStatement"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.forex_kb.arn}/*"]
  }
}
