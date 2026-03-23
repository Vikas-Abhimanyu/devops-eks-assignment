# DevOps Assignment – AWS EKS End-to-End Deployment

This repository contains the **complete infrastructure and application stack** required to deploy a containerized application on **Amazon EKS** using modern DevOps practices.

The project demonstrates:

* Infrastructure provisioning with **Terraform**
* Containerization with **Docker**
* CI/CD automation with **Jenkins**
* Configuration management using **Ansible**
* Application deployment to **Kubernetes**
* Secure secrets handling using **AWS Secrets Manager**
* Monitoring using **CloudWatch**

The goal is to implement a **production-style DevOps architecture** where infrastructure, application build, and deployment are automated.

---

# Architecture Overview

The system provisions and deploys the following AWS resources:

* **VPC** with public and private subnets
* **Amazon EKS Cluster**
* **Amazon RDS (MySQL/Postgres)** for application database
* **AWS Secrets Manager** for application credentials
* **Amazon ECR** for Docker image storage
* **Bastion Host** for cluster access
* **Jenkins Server** for CI/CD pipeline execution
* **Ansible Server** for automation tasks
* **AWS Load Balancer Controller** for Kubernetes ingress
* **CloudWatch** for logs, metrics, and alerts

Deployment flow:

```
Developer → GitHub
       ↓
Jenkins Pipeline
       ↓
Docker Build
       ↓
Push Image → AWS ECR
       ↓
Kubernetes Deployment → Amazon EKS
       ↓
Application exposed via AWS Load Balancer
```

---

# Repository Structure

```
Devops-Assignment
│
├ backend/                # Backend application source code
├ frontend/               # Frontend application source code
├ k8s/                    # Kubernetes manifests
│
├ terraform/              # Infrastructure as Code
│   ├ 01-backend          # Terraform state backend resources
│   ├ 02-network          # VPC, subnets, routing
│   ├ 03-eks              # EKS cluster and node groups
│   ├ 04-security         # IAM roles and service accounts
│   ├ 05-storage          # RDS database infrastructure
│   ├ 06-secrets          # AWS Secrets Manager secrets
│   ├ 07-observability    # CloudWatch logs and alarms
│   ├ 08-compute          # Bastion, Jenkins, Ansible servers
│   ├ 09-kubernetes       # Kubernetes integrations
│   └ 10-ecr              # ECR repositories
│
├ docker-compose.yml      # Local development environment
├ Jenkinsfile             # CI/CD pipeline definition
├ README.md               # Project documentation
```

---

# Infrastructure Deployment

Terraform is organized in **layered states**.
Each directory represents an independent infrastructure component.

Deploy in the following order:

```
01-backend
02-network
03-eks
04-security
05-storage
06-secrets
07-observability
08-compute
09-kubernetes
10-ecr
```

Example deployment:

```
cd terraform/02-network
terraform init
terraform plan
terraform apply
```

Repeat for each layer.

---

# Application Deployment Workflow

1. Developer pushes code to repository
2. Jenkins pipeline triggers automatically
3. Pipeline performs:

   * Docker image build
   * Push image to AWS ECR
   * Deploy updated application to Kubernetes
4. Kubernetes pulls the new image and updates the running pods
5. Application becomes accessible via AWS Load Balancer

---

# Kubernetes Components

The **k8s/** directory contains deployment manifests:

* **Deployment** – application pods
* **Service** – internal cluster access
* **Ingress** – external load balancer
* **SecretProviderClass** – integration with AWS Secrets Manager

These resources run inside the **EKS cluster** created by Terraform.

---

# CI/CD Pipeline

The **Jenkins pipeline** performs:

1. Source code checkout
2. Docker image build
3. Push image to **AWS ECR**
4. Update Kubernetes deployment
5. Trigger rollout on EKS

Pipeline definition is stored in:

```
Jenkinsfile
```

---

# Local Development (Optional)

Run the application locally using Docker:

```
docker-compose up --build
```

---

# Prerequisites

Before running this project ensure the following tools are installed:

* Terraform
* AWS CLI
* Docker
* kubectl
* Helm
* Git

AWS credentials must be configured:

```
aws configure
```

---

# Key Features Implemented

* Infrastructure as Code with Terraform
* Multi-layer Terraform state architecture
* Kubernetes deployment on AWS EKS
* Secure secret injection via AWS Secrets Manager
* CI/CD automation using Jenkins
* Container image management with AWS ECR
* Monitoring and alerting via CloudWatch
* Bastion host for secure cluster access

---

# Purpose of the Project

This project demonstrates how to design and implement a **production-style DevOps platform on AWS**, combining infrastructure automation, container orchestration, and CI/CD pipelines.

It serves as a practical example of building a **complete cloud-native deployment workflow** from infrastructure provisioning to application delivery.

