output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "ecr_repository_uri" {
  description = "URI of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "k3s_server_public_ip" {
  description = "Public IP address of the K3s Server"
  value       = aws_instance.k3s_server.public_ip
}

output "k3s_agent_public_ip" {
  description = "Public IP address of the K3s Agent"
  value       = aws_instance.k3s_agent.public_ip
}
