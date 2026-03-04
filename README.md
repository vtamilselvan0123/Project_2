# Project:Trend_Store – Terraform + Jenkins CI/CD Deployment to AWS EKS with Monitoring

## Overview
This project demonstrates a complete DevOps pipeline using:
- Docker for application containerization
- Terraform for AWS infrastructure provisioning
- Jenkins for CI/CD automation
- AWS EKS for Kubernetes deployment
- DockerHub for storing container images
- Open-source monitoring using Prometheus + Grafana

---

## What I Implemented

### 1) Application Setup
- Cloned the given Git repository.
- Verified the application runs on the required port.

---

### 2) Dockerization
- Created a Dockerfile for the application.
  
- Built the docker image and tested it locally.

---

### 3) Terraform Infrastructure Provisioning
Created Terraform configuration to provision AWS infrastructure including:
- VPC
- Subnet and networking components
- Security Groups
- IAM roles and instance profile
- EC2 instance for Jenkins

Executed:
- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform apply`

---

### 4) Jenkins Installation + Plugins
- Installed Jenkins on the provisioned EC2 instance.
- Installed required Jenkins plugins for CI/CD:
  - Git
  - Docker
  - Kubernetes
  - Pipeline

---

### 5) AWS EKS Cluster Setup
- Created an EKS cluster with worker nodes.
- Installed kubectl and verified cluster access.
- Verified node readiness and connectivity.

---

### 6) Kubernetes Manifests
Created Kubernetes YAML files:
- `deployment.yaml`
- `service.yaml`

---

### 7) CI/CD Pipeline using Jenkins
- Created a declarative Jenkins pipeline.
- Integrated GitHub webhook for auto-trigger builds.
- Pipeline workflow includes:
  - Checkout code
  - Build docker image
  - Push image to DockerHub
  - Deploy application to EKS using kubectl

---

### 8) Monitoring (Open-source)
- Installed Prometheus + Grafana stack inside Kubernetes.
- Verified monitoring namespace and pods are running.
- Accessed Grafana using port-forwarding.
- Verified cluster health and resource monitoring dashboards.

---

## Proof / Screenshots Included
The repository includes screenshots for:
- Terraform provisioning steps and outputs
- AWS console resources (EC2, VPC, Security Groups)
- Jenkins installation and login
- Jenkins job configuration and pipeline execution
- EKS cluster creation and node status
- Kubernetes deployment, pods, and service outputs
- DockerHub push proof
- Prometheus/Grafana monitoring setup and dashboards

---

## Conclusion
This project successfully demonstrates infrastructure automation using Terraform, CI/CD automation using Jenkins, Kubernetes deployment in AWS EKS, DockerHub integration, and open-source monitoring for production readiness.
