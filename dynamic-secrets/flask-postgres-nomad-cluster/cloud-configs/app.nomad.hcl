job "flask-app" {
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

	group "vault-flask-postgres-app" {
		count = 1

		network {
			port "api" {
				to = 5000
			}
		}
			
		update {
			max_parallel     = 1
			min_healthy_time = "30s"
			healthy_deadline = "2m"
		}

		restart {
			attempts = 2
			interval = "1m"

			delay = "10s"
			mode = "fail"
		}

		task "flask-app" {
			driver = "docker"

			config {
				// image = "alirezarpi/vault-dynamic-secrets-flask-postgres-app:latest"
                image = "localhost:5000/vault-dynamic-secrets-flask-postgres-app:latest"
				ports = ["api"]
			}

			service {
				name = "${TASKGROUP}-service"
				tags = ["global", "flask-app", "urlprefix-/"]
				port = "api"
				check {
                    name = "alive"download-sample
                    type = "http"
                    interval = "10s"
                    timeout = "3s"
                    path = "/health/"
				}
			}
            env {
                VERSION=0.0.0
                DB_HOST=postgres-database
                DB_NAME=dvdrental
                DB_USER=postgres
                DB_PASSWORD=postgres
            }

			resources {
				cpu = 256
				memory = 128
			}

			logs {
			    max_files = 10
			    max_file_size = 15
			}

			kill_timeout = "10s"
		}
	}
}