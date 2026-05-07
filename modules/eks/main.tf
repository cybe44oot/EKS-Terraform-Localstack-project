#  EKS IAM Role 
resource "aws_iam_role" "eks_cluster" {
name = "malaa-eks-role"
assume_role_policy = jsonencode({
Version = "2012-10-17"
Statement = [{
Action = "sts:AssumeRole"
Effect = "Allow"
Principal = { Service = "eks.amazonaws.com" }
}]
})
}
resource "aws_iam_role_policy_attachment" "eks_policy" {
role = aws_iam_role.eks_cluster.name
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#  EKS Cluster 

resource "aws_eks_cluster" "main" {
name = "malaa-cluster"
role_arn = aws_iam_role.eks_cluster.arn
vpc_config {
subnet_ids = [var.private_servers_subnet_id]
security_group_ids = [var.servers_sg_id]
}
depends_on = [aws_iam_role_policy_attachment.eks_policy]
tags = { Name = "malaa-cluster" }
}

# Node IAM Role 

resource "aws_iam_role" "eks_nodes" {
name = "malaa-eks-nodes-role"
assume_role_policy = jsonencode({
Version = "2012-10-17"
Statement = [{
Action = "sts:AssumeRole"
Effect = "Allow"
Principal = { Service = "ec2.amazonaws.com" }
}]
})
}
resource "aws_iam_role_policy_attachment" "nodes_worker" {
role = aws_iam_role.eks_nodes.name
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "nodes_cni" {
role = aws_iam_role.eks_nodes.name
policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "nodes_ecr" {
role = aws_iam_role.eks_nodes.name
policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Node Group

resource "aws_eks_node_group" "main" {
cluster_name = aws_eks_cluster.main.name
node_group_name = "malaa-nodes"
node_role_arn = aws_iam_role.eks_nodes.arn
subnet_ids = [var.private_servers_subnet_id]
scaling_config {
desired_size = 3
max_size = 5
min_size = 3
}
instance_types = ["t3.medium"]
depends_on = [
aws_iam_role_policy_attachment.nodes_worker,
aws_iam_role_policy_attachment.nodes_cni,
aws_iam_role_policy_attachment.nodes_ecr,
]
}