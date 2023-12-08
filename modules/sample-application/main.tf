terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
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

provider "kubernetes" {
  host                   = var.host
  client_certificate     = var.client_certificate
  client_key             = var.client_key
  cluster_ca_certificate = var.cluster_ca_certificate
}

locals {
  namespace    = "app"
  service_name = "app"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_ingress_v1" "hello_world_ingress" {
  metadata {
    name      = "hello-world-ingress"
    namespace = local.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" : "false"
      "nginx.ingress.kubernetes.io/use-regex" : "true"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/$2"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = local.service_name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "hello_world_ingress_static" {
  metadata {
    name      = "hello-world-ingress-static"
    namespace = local.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" : "false"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/static/$2"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/static(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = local.service_name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = local.service_name
    namespace = local.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      name = "app"
    }
    port {
      port = 80
    }
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = "app"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        name = "app"
      }
    }
    replicas = 3
    template {
      metadata {
        name = "app"
        labels = {
          name = "app"
        }
      }
      spec {
        container {
          image = "mcr.microsoft.com/azuredocs/aks-helloworld:v1"
          name  = "hello-world"
          port {
            container_port = 80
          }
          env {
            name  = "TITLE"
            value = "Welcome to Kubernetes!"
          }
        }
      }
    }
  }
}
