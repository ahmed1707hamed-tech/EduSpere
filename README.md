# 🎓 EduSphere

> **Enterprise Cloud-Native Learning Management System**

```{=html}
<p align="center">
```
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes)
![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible)
![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazonaws) ![GitHub
Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana)

```{=html}
</p>
```

------------------------------------------------------------------------

## 📖 Overview

EduSphere is a production-ready **Cloud-Native Learning Management
System (LMS)** built with a microservices architecture and modern DevOps
practices. The project demonstrates how to design, containerize, deploy,
automate, monitor, and manage scalable applications on AWS using
Infrastructure as Code and Kubernetes.

------------------------------------------------------------------------

# 🏗️ System Architecture


<p align="center">
```
`<img src="./docs/screenshots/EduSphere_Architecture.png" alt="EduSphere Architecture" width="100%">`{=html}
```{=html}
</p>

------------------------------------------------------------------------

# ✨ Key Features

-   🔐 JWT Authentication & Role-Based Access Control
-   📚 Course Management
-   📝 Quiz & Progress Tracking
-   📄 Certificate Generation
-   📂 Content Management
-   🧩 Microservices Architecture
-   🐳 Docker Containerization
-   ☸️ Kubernetes Deployment
-   📦 Helm Charts
-   ☁️ AWS Cloud Deployment
-   🏗️ Infrastructure as Code (Terraform)
-   ⚙️ Configuration Management (Ansible)
-   🚀 CI/CD with GitHub Actions
-   📊 Monitoring with Prometheus & Grafana
-   📝 Centralized Logging with Loki

------------------------------------------------------------------------

# 🛠️ Technology Stack

  Category          Technologies
  ----------------- ---------------------------
  Backend           Python, FastAPI
  Frontend          React, Tailwind CSS
  Database          PostgreSQL
  Cache             Redis
  Containers        Docker, Docker Compose
  Orchestration     Kubernetes (k3s), Helm
  IaC               Terraform
  Configuration     Ansible
  Monitoring        Prometheus, Grafana, Loki
  Cloud             AWS EC2, VPC, S3
  CI/CD             GitHub Actions
  Version Control   Git, GitHub

------------------------------------------------------------------------

# 📂 Repository Structure

``` text
EduSphere
├── .github/
├── database/
├── docs/
│   └── screenshots/
│       └── EduSphere_Architecture.png
├── frontend/
├── helm/
├── infrastructure/
├── kubernetes/
├── monitoring/
├── scripts/
├── services/
├── terraform/
├── docker-compose.yml
├── Makefile
└── README.md
```

------------------------------------------------------------------------

# 🧩 Microservices

-   Authentication Service
-   Course Management Service
-   Content Service
-   Quiz & Progress Service
-   Notification Service
-   API Gateway

------------------------------------------------------------------------

# ☁️ Infrastructure

-   AWS EC2
-   VPC
-   Public & Private Networking
-   Security Groups
-   Amazon S3
-   Route Tables
-   Internet Gateway

Provisioned using **Terraform**.

------------------------------------------------------------------------

# 🐳 Containerization

Each microservice is packaged using Docker with its own Dockerfile.
Docker Compose is used for local development and integration testing.

------------------------------------------------------------------------

# ☸️ Kubernetes

Deployment resources include:

-   Deployments
-   Services
-   ConfigMaps
-   Secrets
-   Ingress
-   Helm Charts

------------------------------------------------------------------------

# ⚙️ Configuration Management

Infrastructure configuration and provisioning are automated using
**Ansible** roles and playbooks.

------------------------------------------------------------------------

# 🚀 CI/CD Pipeline

``` text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ▼
Build Docker Images
    │
    ▼
Deploy using Helm
    │
    ▼
Kubernetes Cluster
```

------------------------------------------------------------------------

# 📊 Monitoring & Logging

-   Prometheus
-   Grafana
-   Loki

Metrics monitored:

-   CPU Usage
-   Memory Usage
-   Pod Health
-   Application Logs
-   Resource Utilization

------------------------------------------------------------------------

# 🔐 Security

-   JWT Authentication
-   RBAC
-   Kubernetes Secrets
-   Environment Variables
-   Secure Docker Images
-   Least Privilege Access

------------------------------------------------------------------------

# ⚡ Getting Started

``` bash
git clone https://github.com/ahmed1707hamed-tech/EduSphere.git
cd EduSphere
docker compose up -d
```

Deploy to Kubernetes:

``` bash
helm install edusphere ./helm
```

------------------------------------------------------------------------

# 📈 Future Improvements

-   Horizontal Pod Autoscaling
-   Argo CD GitOps
-   SonarQube Integration
-   Trivy Image Scanning
-   AWS EKS Production Deployment

------------------------------------------------------------------------

# 👨‍💻 Author

**Ahmed Mohammed Hamed**

Cloud & DevOps Engineer

-   Faculty of Computers and Information
-   Mansoura University

GitHub: https://github.com/ahmed1707hamed-tech

LinkedIn: https://www.linkedin.com/in/ahmed-hamed-340570364?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app

------------------------------------------------------------------------

⭐ If you found this project useful, consider giving it a star!
