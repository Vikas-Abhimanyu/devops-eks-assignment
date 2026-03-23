# DevOps EKS Assignment – End-to-End AWS Deployment

This repository contains the **complete infrastructure and application stack** to deploy a **three-tier containerized application** on **Amazon EKS**, demonstrating modern DevOps practices.

The project implements:

* Infrastructure provisioning using **Terraform** with modular design
* Containerization using **Docker** (multi-stage, non-root images)
* CI/CD automation via **Jenkins**
* Configuration management with **Ansible** (including Jenkins setup and secrets handling)
* Application deployment on **Kubernetes** using manifests
* Secure secrets injection via **AWS Secrets Manager**
* Monitoring, logging, and alerts using **AWS CloudWatch**  

The goal is a **production-style DevOps workflow** automating infrastructure, builds, and deployments.

---

## Architecture Overview

The infrastructure provisions the following AWS resources:

* **VPC** with public and private subnets, Internet Gateway, and NAT
* **Amazon EKS Cluster** with managed node groups
* **Amazon RDS (Postgres)** for backend database
* **AWS Secrets Manager** for storing DB credentials and API keys
* **Amazon ECR** for backend and frontend Docker images
* **Bastion Host** for secure SSH access
* **Jenkins Server** for CI/CD pipeline execution
* **Ansible Server** for automation tasks and bootstrapping
* **AWS Load Balancer Controller** for Kubernetes Ingress
* **CloudWatch** for metrics, logs, and alerts (with SNS notifications)

---

## Deployment Flow


Developer → GitHub
↓
Jenkins Pipeline
↓
Docker Build (Backend + Frontend)
↓
Push Images → AWS ECR
↓
Kubernetes Deployment → Amazon EKS
↓
Secrets injected via AWS Secrets Manager CSI driver
↓
Application exposed via AWS Load Balancer
↓
Monitoring & Alerts via CloudWatch + SNS


---

## Repository Structure


devops-eks-assignment
│
OAOAOA├ backend/ # Flask backend API
│ ├ app.py
│ ├ Dockerfile
│ └ requirements.txt
├ frontend/ # Static frontend (HTML/JS)
│ ├ Dockerfile
│ └ index.html
├ k8s/ # Kubernetes manifests
│ ├ backend-deployment.yaml
│ ├ backend-service.yaml
│ ├ frontend-deployment.yaml
OAOAOA│ ├ frontend-service.yaml
│ ├ ingress.yaml
OAOAOA│ └ secret-provider.yaml
├ terraform/ # Infrastructure as Code
OAOAOA│ ├ modules/ # VPC, EKS, Compute, IAM, Secrets, RDS, ECR, Monitoring, Kubernetes, State
│ ├ provider.tf
│ ├ main.tf
│ ├ variables.tf
│ └ outputs.tf
├ docker-compose.yml # Local testing environment
├ Jenkinsfile # CI/CD pipeline
├ ansible/ # Playbooks and vault for Jenkins & AWS CLI setup
└ README.md # Project documentation


---

## Infrastructure Deployment

Terraform provisions the **entire AWS stack**, including:

* VPC, Subnets, NAT, Internet Gateway, and Routing
* EKS Cluster and Node Groups
OAOAOA* IAM Roles and Policies
* Bastion, Jenkins, and Ansible EC2 Hosts
* RDS Postgres Database
* AWS Secrets Manager for DB/API credentials
OAOAOA* ECR Repositories
* CloudWatch Logs, Metrics, and Alerts

OAOAOA**Deployment order** (module-wise):

1. `terraform/modules/state` – S3 backend & DynamoDB locking  
2. `terraform/modules/vpc` – VPC and subnets  
3. `terraform/modules/eks` – EKS cluster + node groups  
4. `terraform/modules/iam` – IAM roles for EKS & secrets access  
5. `terraform/modules/rds` – Postgres database  
6. `terraform/modules/secrets` – AWS Secrets Manager  
7. `terraform/modules/monitoring` – CloudWatch logs & alarms  
8. `terraform/modules/compute` – Bastion, Jenkins, and Ansible EC2 hosts  
9. `terraform/modules/kubernetes` – Kubernetes Helm charts for Secrets Store CSI & ALB controller  
10. `terraform/modules/ecr` – Backend and Frontend repositories  

Example:

```bash
cd terraform
terraform init
terraform apply -auto-approve
Ansible Setup

Ansible configures Jenkins and optionally bootstraps the environment:

AWS CLI setup using Ansible Vault
kubectl configuration for EKS access
Pipeline credentials from Vault

Run playbook:

ansible-playbook -i inventory playbook.yml --ask-vault-pass
Application Deployment Workflow
Developer pushes code to GitHub
Jenkins pipeline executes:
Terraform init & apply (if infra not provisioned)
Docker build for backend & frontend (non-root images)
Push images to AWS ECR
Apply Kubernetes manifests on EKS
Secrets injected from AWS Secrets Manager
Pods rollout automatically
Application is accessible via AWS Load Balancer
Logs and metrics are collected in CloudWatch with alarms sent to SNS
Kubernetes Components

Kubernetes manifests in k8s/:

Deployment – Backend API and Frontend pods
Service – Internal networking
Ingress – External access via ALB
SecretProviderClass – Integrates AWS Secrets Manager via CSI driver
Jenkins CI/CD Pipeline

Pipeline stored in Jenkinsfile performs:

Terraform init & apply
Docker image build (backend + frontend)
Push to AWS ECR
Apply Kubernetes manifests
Trigger rollout on pods

All secrets are stored securely via:

AWS Secrets Manager
Jenkins Credentials / Ansible Vault

No secrets are in Git.

Local Development (Optional)

Run the application locally using Docker Compose:

./make-env.sh   # Generates .env with Terraform & Secrets Manager values
docker-compose up --build
Prerequisites
Terraform >= 1.5
AWS CLI
Docker
kubectl
Helm
Git
Ansible

AWS credentials must be configured:

aws configure
Key Features
Modular Terraform architecture with state management (S3 + DynamoDB locking + versioning)
Multi-stage non-root Docker images
Kubernetes deployment on Amazon EKS
Secure secrets injection via AWS Secrets Manager
CI/CD automation using Jenkins
Bastion host for secure access
CloudWatch monitoring, logging, and alerts
Purpose

This project demonstrates a production-style DevOps platform on AWS, from infrastructure provisioning to deployment, with a focus on automation, security, and observability.
