
resource "aws_codedeploy_app" "original_api_app" {
  compute_platform = "Server" # Lightsailインスタンスは EC2 (Server) プラットフォームとして扱われます
  name             = "original-api-deploy"
}

resource "aws_codedeploy_deployment_group" "original_api_dg" {
  app_name             = aws_codedeploy_app.original_api_app.name
  deployment_config_name = "CodeDeployDefault.AllAtOnce" # デプロイ戦略
  deployment_group_name  = "original-api-deploy-group"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  
  # immportでとりこめなさそう・・再構築時に検証
  #on_premises_instance_tag_filter {
  #  key   = "Name"
  #  type  = "KEY_AND_VALUE"
  #  value = "CodeDeployMyLightsail"
  #}
}

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy" "codedeploy_policy" {
  name        = "CodeDeployPolicy"
  description = "Permissions for CodeDeploy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ],
        Resource = "arn:aws:s3:::codepipeline-bucket-original-api-artifact/*" # アプリケーションリビジョンが格納された S3 バケット
      },
      {
        Effect   = "Allow"
        Action   = [
            "lightsail:GetInstance",
            "lightsail:GetInstances",
            "lightsail:StartInstance",
            "lightsail:StopInstance",
            "lightsail:RebootInstance"
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_service_role_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = aws_iam_policy.codedeploy_policy.arn
}