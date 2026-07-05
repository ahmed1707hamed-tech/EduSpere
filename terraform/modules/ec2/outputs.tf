output "instance_ids" {
  description = "k3s EC2 instance IDs."
  value       = aws_instance.k3s[*].id
}

output "private_ips" {
  description = "k3s EC2 private IP addresses."
  value       = aws_instance.k3s[*].private_ip
}

output "instance_arns" {
  description = "k3s EC2 instance ARNs."
  value       = aws_instance.k3s[*].arn
}

output "ami_id" {
  description = "AMI ID used by k3s hosts."
  value       = coalesce(var.ami_id, data.aws_ami.amazon_linux[0].id)
}
