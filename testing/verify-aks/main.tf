terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
  }
}

variable "host" {
  type      = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type      = string
  sensitive = true
}

data "kubernetes_service_account" "default" {
  metadata {
    name = "default"
  }
}

resource "kubernetes_secret" "token" {
  metadata {
    name = "default-token"
    annotations = {
      "kubernetes.io/service-account.name" = data.kubernetes_service_account.default.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}

data "http" "api" {
  method      = "GET"
  url         = "${var.host}/api"
  ca_cert_pem = var.cluster_ca_certificate
  request_headers = {
    "Authorization" = "Bearer ${kubernetes_secret.token.data.token}"
  }
}

data "http" "api" {
  method      = "GET"
  url         = "${var.host}/api"
  ca_cert_pem = var.cluster_ca_certificate
  request_headers = {
    "Authorization" = "Bearer ${kubernetes_secret.token.data.token}"
  }
}
