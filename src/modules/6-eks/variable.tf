variable "eks_ec2_policy" {
  default = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

variable "eks_cni_policy" {
  default = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

variable "eks_worker_policy" {
  default = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

variable "eks_cluster_policy" {
  default = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

variable "eks_node_group_name" {
  default = "eks-fiap-nodes"
}

variable "eks_cluster_name" {
  default = "eks-fiap-cluster"
}

variable "eks_cluster_role_name" {
  default = "eks-fiap-cluster-role"
}

variable "eks_cluster_sg_name" {
  default = "eks-fiap-cluster-sg"
}

variable "eks_worker_role_name" {
  default = "eks-fiap-wkr-role"
}

variable "vpc_id" {
  type = string
}

variable "cidr_block" { 
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "dynamodb_access_policy_arn" {
  type = string
}