output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster name."
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS cluster API server endpoint."
}

output "cluster_ca_certificate" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Base64-encoded EKS cluster CA certificate."
}
