output "cluster_arn" {
  value       = module.eks.cluster_arn
  description = "The Amazon Resource Name (ARN) of the cluster"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the cluster"
}

output "cluster_id" {
  value       = module.eks.cluster_id
  description = "The unique id of the cluster"

}

output "cluster_certificate_authority" {
  value       = module.eks.cluster_certificate_authority_data
  description = "The certificate authority of the cluster"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint for your Kubernetes API server"
}

output "caller_identity" {
  value       = data.aws_caller_identity.current
  description = "The caller identity"
}

output "vpc-id" {
  value = module.vpc.vpc_id
}

output "acm_certificate_id" {
  value = aws_acm_certificate.acm_cert.id 
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.acm_cert.arn
}

output "acm_certificate_status" {
  value = aws_acm_certificate.acm_cert.status
}