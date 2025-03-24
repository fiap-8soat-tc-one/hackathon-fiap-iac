output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "security_group_id" {
  value = aws_security_group.eks_cluster.id
}