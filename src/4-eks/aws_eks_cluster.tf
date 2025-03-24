resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.public_subnet_ids
    security_group_ids = [aws_security_group.eks_cluster.id]
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }

  subnet_ids     = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  instance_types = ["t3.medium"]
}

