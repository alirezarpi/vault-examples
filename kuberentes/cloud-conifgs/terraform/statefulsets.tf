resource "kubernetes_stateful_set" "redis" {
  metadata {
    annotations = {
      vault.hashicorp.com/agent-inject = "true"
      vault.hashicorp.com/role = "the-flask-app-policy"
      vault.hashicorp.com/agent-inject-secret-redis-config.txt = "tfa/data/redis/config"
    }

    labels = {
      app                               = "redis"
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
      version                           = "v2.2.1"
    }

    name = "redis"
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = 1
    revision_history_limit = 5

    selector {
      match_labels = {
        app = "redis"
      }
    }

    service_name = "redis"

    template {
      metadata {
        labels = {
          app = "redis"
        }

        annotations = {
            "vault.hashicorp.com/agent-inject": "true",
            "vault.hashicorp.com/role": "the-flask-app-policy",
            "vault.hashicorp.com/agent-inject-secret-redis-config.txt": "tfa/data/redis/config"
        }
      }

      spec {
        service_account_name = "k8s-service-acct"

        container {
          name              = "redis-server"
          image             = "library/redis:3.2"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 6379
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "1000Mi"
            }

            requests = {
              cpu    = "200m"
              memory = "1000Mi"
            }
          }

        termination_grace_period_seconds = 300
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }
  }
}
}