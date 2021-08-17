job "the-flask-app-database" {
    datacenters = ["local-dc"]
    type = "service"

    constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}

    group "the-flask-app-database-group" {
        network {
            port "db"{
                static = 5432
            }
			dns {
				servers = ["10.0.2.15"]
				searches = ["service.consul"]
			}
            mode = "bridge"
        }

        service {
            name = "${TASKGROUP}-service"
            tags = ["database"]
            port = "db"
        }

        volume "database-data" {
            type      = "host"
            read_only = false
            source    = "database-data"
        }

        task "postgres-database" {
            driver = "docker"

            volume_mount {
                volume      = "database-data"
                destination = "/var/lib/postgresql/data"
                read_only   = false
            }

            vault {
                policies  = ["database-access"]
            }

            config {
                image = "postgres:12-alpine"
                ports = ["db"]
            }
            
            template {
                data = <<EOT
        {{ with secret "kv/database" }}
POSTGRES_USER="{{ .Data.user }}"
POSTGRES_PASSWORD="{{ .Data.password | toJSON }}"
POSTGRES_DB="dvdrental"
        {{ end }}
EOT
        destination = "db.env"
        env         = true
            }
        }
    }
}
