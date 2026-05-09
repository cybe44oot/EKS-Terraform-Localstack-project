terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    ec2   = "http://localhost:4566"
    elb   = "http://localhost:4566"
    elbv2 = "http://localhost:4566"
    eks   = "http://localhost:4566"
    iam   = "http://localhost:4566"
    sts   = "http://localhost:4566"
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/localstack-k3d.yaml")
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/localstack-k3d.yaml")
  }
}

module "network" {
  source = "./modules/network"
}

module "eks" {
  source                    = "./modules/eks"
  private_servers_subnet_id = module.network.private_servers_subnet_id
  servers_sg_id             = module.network.servers_sg_id
}

module "apps" {
  source = "./modules/apps"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.eks]
}

module "observability" {
  source = "./modules/observability"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.eks]
}