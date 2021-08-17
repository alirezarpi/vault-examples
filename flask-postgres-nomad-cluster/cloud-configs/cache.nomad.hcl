job "the-flask-app-cache" {
	datacenters = ["local-dc"]
    type = "service"

    update {
        max_parallel = 1
        min_healthy_time = "10s"

        healthy_deadline = "3m"
        auto_revert = false
    }

    group "the-flask-app-cache-group" {
        count = 1

        restart {
            attempts = 10
            interval = "5m"
            delay = "25s"
            mode = "delay"
        }

        volume "cache-data" {
            type      = "host"
            read_only = false
            source    = "cache-data"
        }

        network {
            port "db" {
                static = 6379
            }
			dns {
				servers = ["10.0.2.15"]
				searches = ["service.consul"]
			}
            mode = "bridge"
        }

        service {
            name = "${TASKGROUP}-service"
            tags = ["cache"]
            port = "db"
        }

        ephemeral_disk {
            size = 300
        }

        task "cache" {
            driver = "docker"

            volume_mount {
                volume      = "cache-data"
                destination = "/data"
                read_only   = false
            }

            config {
                image = "redis:3.2"
                ports = ["db"]
            }

            resources {
                cpu    = 100
                memory = 128 
            }
        }
    }
}