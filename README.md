# React + Vite DevOps Infrastructure

This repository contains a complete, AWS Free Tier eligible DevOps infrastructure for a React + Vite frontend application. It uses Terraform to provision `t3.micro` EC2 instances, Docker for containerization, K3s for lightweight Kubernetes orchestration, and Jenkins for CI/CD.

## Architecture

```text
GitHub (Push)
     │
     ▼ (Webhook)
  Jenkins (t3.micro) ────┐
     │ (Build & Push)    │ (kubectl deploy via SSM kubeconfig)
     ▼                   ▼
 AWS ECR               K3s Master (t3.micro)
     │                   │
     └──────(Pull)───────┤
                         ▼
                     K3s Agent (t3.micro)
                         │
                         ▼
                       User (Public IP on Port 80)
```

## Prerequisites

- [AWS CLI](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/index.html) configured with necessary permissions.
- [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.5.0 or later.
- AWS Key Pair created in your target region for EC2 SSH access.

## Step-by-Step Provisioning Guide

### 1. Provision Infrastructure with Terraform

Navigate to the `terraform` directory:

```bash
cd terraform
```

Copy the example variables file and update it with your desired values (e.g., your AWS region and key pair name):

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars as needed
```

Initialize, plan, and apply the Terraform configuration:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

After successful apply, take note of the outputs:
- `jenkins_public_ip`
- `ecr_repository_uri`
- `k3s_server_public_ip`
- `k3s_agent_public_ip`

### 2. Jenkins Initial Setup

1. Access the Jenkins UI via `http://<jenkins_public_ip>:8080`.
2. Retrieve the initial admin password from the Jenkins server:
   ```bash
   ssh -i <your-key.pem> ubuntu@<jenkins_public_ip>
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Complete the Jenkins setup wizard (Install suggested plugins).
4. Create an Admin user.
5. In Jenkins, navigate to **Manage Jenkins** > **Credentials** > **System** > **Global credentials (unrestricted)**. Add the following credentials:
   - `Secret text`: `aws-access-key` (Your AWS Access Key ID)
   - `Secret text`: `aws-secret-key` (Your AWS Secret Access Key)
   - `Secret text`: `github-token` (Your GitHub Personal Access Token, if pulling private repos)

### 3. Pipeline Configuration

1. Create a new **Pipeline** job in Jenkins.
2. In the Pipeline section, choose **Pipeline script from SCM**.
3. Select Git, enter your repository URL.
4. Set the script path to `app/Jenkinsfile`.
5. Run the pipeline. This will:
   - Build the React app.
   - Build the Docker image.
   - Push the image to AWS ECR.
   - Deploy the new image to K3s using the kubeconfig retrieved from AWS SSM.

### 4. Verification

After the pipeline successfully deploys the app, verify the application by navigating to the K3s server or agent public IPs:

```bash
http://<k3s_server_public_ip>
http://<k3s_agent_public_ip>
```
Because of Klipper ServiceLB, port 80 is forwarded to the React Application from any of the cluster nodes!

## Cleanup

To avoid incurring future charges, destroy the infrastructure when no longer needed:

```bash
cd terraform
terraform destroy -auto-approve
```
