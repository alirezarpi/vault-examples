job "the-flask-app" {
	datacenters = ["local-dc"]
	type = "service"

	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}

	update {
		stagger = "10s"
		max_parallel = 1
	}

	group "the-flask-app-group" {
		count = 3

		network {
			port "api" {
				to = 5000
			}
			dns {
				servers = ["10.0.2.15"]
				searches = ["service.consul"]
			}
			mode = "bridge"
		}
			
		service {
			name = "${TASKGROUP}-service"
			tags = ["flask-app", "urlprefix-/"]
			port = "api"
			check {
				name = "alive"
				type = "http"
				interval = "10s"
				timeout = "3s"
				path = "/health/"
			}
		}

		update {
			max_parallel     = 1
			min_healthy_time = "5s"
			healthy_deadline = "9m"
		}

		restart {
			attempts = 2
			interval = "1m"

			delay = "10s"
			mode = "fail"
		}

		task "app" {
			driver = "docker"

			vault {
				policies = ["database-dynamic-access"]
			}

			config {
				image = "alirezarpi/the-flask-app:latest"
				// uncomment line below if you pushed the image in the registry of yours in vagrant
                // image = "localhost:5000/vault-dynamic-secrets-flask-postgres-app:latest"
				ports = ["api"]
			}


			template {
                data = <<EOT
VERSION=0.0.1
CACHE_HOST=the-flask-app-cache-group-service.service.consul
{{- range service "the-flask-app-cache-group-service" }}
CACHE_PORT={{ .Port }}
{{ end }}
DB_HOST=the-flask-app-database-group-service.service.consul
DB_NAME="dvdrental"
{{ with secret "database/creds/postgres-database-role" }}
DB_USER="{{ .Data.username }}"
DB_PASSWORD="{{ .Data.password | toJSON }}"
{{ end }}
EOT
				destination   = "db.env"
				env           = true
            }

			resources {
				cpu = 128
				memory = 64
			}

			logs {
			    max_files = 10
			    max_file_size = 15
			}

			kill_timeout = "10s"
		}
	}
}
