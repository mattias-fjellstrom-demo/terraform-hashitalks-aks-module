terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}

variable "host" {
  type = string
}

variable "client_certificate" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = var.client_certificate
    client_key             = var.client_key
    cluster_ca_certificate = var.cluster_ca_certificate
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  namespace        = "ingress-basic"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  set {
    name  = "controller.replicaCount"
    value = "3"
  }
}
