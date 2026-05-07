# Devops Mini Project

secure network architecture and Kubernetes cluster provisioning using Terraform and LocalStack.

##  Project Overview

This project implements a three-phase DevOps infrastructure exercise:
- **Phase 1:** Secure VPC network with multi-tiered subnets and security groups
- **Phase 2:** EKS Kubernetes cluster with managed node groups and proper IAM
- **Phase 3:** Observability 

**Status:** Phases 1 & 2 Complete ✅ | Phase 3 In Progress

## Architecture

### Network Architecture (Phase 1)

```
Internet User
    ↓
[Public Load Balancer - Port 80/443]  ← Public LB Subnet (10.0.1.0/24)
    ↓
[Firewall/IDS-IPS]  ← Private DMZ Subnet (10.0.2.0/24)
    ↓
[Application Servers] ← Private Servers Subnet (10.0.3.0/24)
    ↓
[Database Servers] ← Private Database Subnet (10.0.4.0/24)
```

**VPC CIDR:** 10.0.0.0/16  
**Security Model:** Cascading access with least-privilege security groups

### Kubernetes Cluster (Phase 2)

```
EKS Control Plane (AWS-managed)
    ↓

k3d-malaa-cluster-551a3403-agent-malaa-nodes-0-0   Ready    <none>          13h   v1.35.3+k3s1
k3d-malaa-cluster-551a3403-agent-malaa-nodes-1-0   Ready    <none>          13h   v1.35.3+k3s1
k3d-malaa-cluster-551a3403-agent-malaa-nodes-2-0   Ready    <none>          13h   v1.35.3+k3s1
k3d-malaa-cluster-551a3403-server-0                Ready    control-plane   13h   v1.35.3+k3s1

```

**Cluster Name:** malaa-cluster  

##  Project Structure

```
malaa-devops/
├── README.md                           
├── .gitignore                
├── main.tf                          
├── variables.tf                        
├── outputs.tf                       
│
└── modules/
    ├── network/                        # Phase 1: Network Infrastructure
    │   ├── provider.tf              
    │   ├── vpc.tf           
    │   ├── subnets.tf                  # 4 subnets (public + 3 private)
    │   ├── routes.tf                 
    │   ├── security_groups.tf      
    │   ├── load_balancers.tf           # 1 public ALB + 2 private NLBs
    │   ├── variables.tf               
    │   └── outputs.tf         
    │
    ├── eks/                            # Phase 2: EKS Cluster
    │   ├── main.tf                     # IAM roles, cluster, node group
    │   ├── provider.tf             
    │   ├── variables.tf      
    │   └── outputs.tf           
    
  

```

##  Quick Start

### Prerequisites

**Ensure you have installed:**
- Terraform 1.5+ ([download](https://developer.hashicorp.com/terraform/downloads))
- Docker Desktop ([download](https://www.docker.com/products/docker-desktop))
- AWS CLI v2 ([download](https://aws.amazon.com/cli/))
- kubectl ([download](https://kubernetes.io/docs/tasks/tools/))
- Helm ([download](https://helm.sh/docs/intro/install/))

**Windows users:** Install via winget
```powershell
winget install Hashicorp.Terraform
winget install Amazon.AWSCLI
winget install Kubernetes.kubectl
winget install Helm.Helm
winget install Docker.DockerDesktop
```

### Installation

**1. Install tflocal** (Terraform + LocalStack wrapper)
```bash
pip install terraform-local
```

**2. Clone this repository**
```bash
git clone https://github.com/your-username/malaa-devops.git
cd malaa-devops
```

**3. Configure AWS CLI for LocalStack**
```bash
aws configure --profile localstack
# AWS Access Key ID:     test
# AWS Secret Access Key: test
# Default region:        us-east-1
# Default output format: json
```

### Deployment

**Phase 1 & 2: Network + EKS Cluster**

```bash
# 1. Start LocalStack in a separate terminal
winget install localstack
localstack auth set-token <the token generated from the website>
localstack start

# 2. In another terminal, initialize Terraform
cd malaa-devops
tflocal init

# 3. Preview changes
tflocal plan

# 4. Apply infrastructure
tflocal apply -auto-approve

# Wait 2-3 minutes for cluster startup...

# 5. Configure kubectl
aws eks update-kubeconfig \
  --region us-east-1 \
  --name malaa-cluster \
  --endpoint-url http://localhost:4566 \
  --profile localstack

# 6. Verify cluster is ready
kubectl get nodes
# Expected: 4 nodes (3 workers + 1 control plane), all Ready

k3d-malaa-cluster-551a3403-agent-malaa-nodes-0-0   Ready    <none>          13h   v1.35.3+k3s1
k3d-malaa-cluster-551a3403-agent-malaa-nodes-1-0   Ready    <none>          13h   v1.35.3+k3s1
k3d-malaa-cluster-551a3403-agent-malaa-nodes-2-0   Ready    <none>          13h   v1.35.3+k3s1
k3d-malaa-cluster-551a3403-server-0                Ready    control-plane   13h   v1.35.3+k3s1

```



### AWS CLI Commands (via LocalStack)

```bash
# List VPCs
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs --profile localstack

# List subnets
aws --endpoint-url=http://localhost:4566 ec2 describe-subnets --profile localstack

# List security groups
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups --profile localstack

# List EKS clusters
aws --endpoint-url=http://localhost:4566 eks list-clusters --profile localstack
```


**Last Updated:** May 2026  
**Next Phase:** Phase 3 - Observability & Logging Stack
