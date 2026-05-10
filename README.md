# Devops Mini Project

secure network architecture and Kubernetes cluster provisioning using Terraform and LocalStack.

##  Project Overview

This project implements a three-phase DevOps infrastructure exercise:
- **Phase 1:** Secure VPC network with multi-tiered subnets and security groups
- **Phase 2:** EKS Kubernetes cluster with managed node groups and proper IAM
- **Phase 3:** Observability 

**Status:** Phases 1 & 2 Complete ✅ | Phase 3 In Progress


##  Project Structure

```
EKS-Terraform-Localstack-project/
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

## Architecture

### Network Components

```text
VPC CIDR: 10.0.0.0/16

Public LB Subnet:         10.0.1.0/24
Private DMZ Subnet:       10.0.2.0/24
Private Servers Subnet:   10.0.3.0/24
Private Database Subnet:  10.0.4.0/24
```

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

### Kubernetes Cluster (Phase 2)The Kubernetes cluster is working successfully.

Cluster verification command:

```powershell
k get nodes
```

Current output:

```text
NAME                                               STATUS   ROLES           AGE    VERSION
k3d-malaa-cluster-fefcc08e-agent-malaa-nodes-0-0   Ready    <none>          155m   v1.35.3+k3s1
k3d-malaa-cluster-fefcc08e-agent-malaa-nodes-1-0   Ready    <none>          155m   v1.35.3+k3s1
k3d-malaa-cluster-fefcc08e-agent-malaa-nodes-2-0   Ready    <none>          155m   v1.35.3+k3s1
k3d-malaa-cluster-fefcc08e-server-0                Ready    control-plane   156m   v1.35.3+k3s1
```

This confirms that the Kubernetes cluster is running with:

```text
1 control-plane node
3 worker nodes
All nodes are Ready
```

---
## Application Deployment

A demo API application has been deployed successfully inside the Kubernetes cluster.

The application is running and responding correctly.

### Test Application Directly

Command:

```powershell
curl.exe http://localhost:5050
```

Output:

```text
/ - Hello World! Host:demo-api-68dcb9c946-bbzm8/10.42.1.23
```

This confirms that the application is reachable directly through local port forwarding.

---

## Ingress Routing

Ingress has been created to route external HTTP traffic to the application inside the Kubernetes cluster.

The application is also working through the Ingress route.

### Test Application Through Ingress

Command:

```powershell
curl.exe http://localhost:8080 -H "Host: api.malaa.local"
```

Output:

```text
/ - Hello World! Host:demo-api-68dcb9c946-bbzm8/10.42.1.23
```

This confirms that the Ingress is routing traffic correctly using the host:

```text
test with Metal-LB :

docker run --rm --network k3d-malaa-cluster-fefcc08e curlimages/curl:latest http://172.20.0.200 -H "Host: api.malaa.local"

Unable to find image 'curlimages/curl:latest' locally
latest: Pulling from curlimages/curl
b6066d233986: Pull complete
Digest: sha256:b3f1fb2a51d923260350d21b8654bbc607164a987e2f7c84a0ac199a67df812a
Status: Downloaded newer image for curlimages/curl:latest
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      0                              0/ - Hello World! Host:demo-api-68dcb9c946-s100     58 100     58   0      0     72      0                              0

```

```text
api.malaa.local
```

Traffic flow:

```text
User Request
    ↓
localhost:8080
    ↓
Ingress Controller
    ↓
Ingress Rule: api.malaa.local
    ↓
Kubernetes Service
    ↓
Demo API Pods
```

---


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
git clone https://github.com/cybe44oot/EKS-Terraform-Localstack-project.git
cd EKS-Terraform-Localstack-project
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

NAME                                               STATUS   ROLES           AGE    VERSION
k3d-malaa-cluster-fefcc08e-agent-malaa-nodes-0-0   Ready    <none>          155m   v1.35.3+k3s1
k3d-malaa-cluster-fefcc08e-agent-malaa-nodes-1-0   Ready    <none>          155m   v1.35.3+k3s1
k3d-malaa-cluster-fefcc08e-agent-malaa-nodes-2-0   Ready    <none>          155m   v1.35.3+k3s1
k3d-malaa-cluster-fefcc08e-server-0                Ready    control-plane   156m   v1.35.3+k3s1

```




## Verify Phase 1: Network Infrastructure

Use the following AWS CLI commands with LocalStack.

### Check VPCs

```powershell
aws ec2 describe-vpcs `
  --region us-east-1 `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```

### Check Subnets

```powershell
aws ec2 describe-subnets `
  --region us-east-1 `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```

### Check Internet Gateway

```powershell
aws ec2 describe-internet-gateways `
  --region us-east-1 `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```

### Check Route Tables

```powershell
aws ec2 describe-route-tables `
  --region us-east-1 `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```

### Check Security Groups

```powershell
aws ec2 describe-security-groups `
  --region us-east-1 `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```

### Check Load Balancers

```powershell
aws elbv2 describe-load-balancers `
  --region us-east-1 `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```

These commands verify that Phase 1 network resources were created successfully.

---

## Verify Phase 2: Kubernetes / EKS

### List EKS Clusters

```powershell
aws eks list-clusters `
  --region us-east-1 `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```

### Describe EKS Cluster

```powershell
aws eks describe-cluster `
  --region us-east-1 `
  --name malaa-cluster `
  --endpoint-url http://localhost:4566 `
  --profile localstack
```


## Next Phase

Phase 3: Observability and Logging Stack

Planned work:

```text
Deploy Grafana
Deploy Loki
Deploy Vector
Collect Kubernetes logs
Collect application logs
Visualize logs in Grafana
Test application logs from demo-api
```


If there is anything I did not fully understand, or if I have any doubts while continuing the implementation, I will come back and ask for guidance.
