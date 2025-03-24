resource "aws_iam_role" "eks_cluster_role" {
  name = var.eks_cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "eks_worker_role" {
  name = var.eks_worker_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = var.eks_cluster_policy
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = var.eks_worker_policy
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = var.eks_cni_policy
}

resource "aws_iam_role_policy_attachment" "eks_ec2_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = var.eks_ec2_policy
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_to_worker_role" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = data.terraform_remote_state.dynamodb.outputs.access_policy_arn
}
