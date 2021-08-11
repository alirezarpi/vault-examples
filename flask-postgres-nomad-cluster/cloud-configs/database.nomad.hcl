job "vault-flask-postgres-database" {
    datacenters = ["local-dc"]
    type = "service"

    constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}

    group "vault-flask-postgres-database" {
        network {
            port "db"{
                static = 5432
            }

            mode = "bridge"
        }

        service {
            name = "${TASKGROUP}-service"
            tags = ["database"]
            port = "db"
        }

        task "postgres-database" {
            driver = "docker"

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
