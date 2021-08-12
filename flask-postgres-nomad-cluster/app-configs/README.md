# Flask Redis Sample Application

## Build

`$ docker build -t alirezarpi/vault-dynamic-secrets-flask-postgres-app:latest .`

## Pull
`$ docker pull alirezarpi/vault-dynamic-secrets-flask-postgres-app:latest`

## Test Run
### Run Database
`$ docker run -d --name vault-dynamic-secrets-flask-postgres-database --network host -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -d postgres:12-alpine`
### Run the flask app
`$ docker run -it --rm --name vault-dynamic-secrets-flask-postgres-app --network host -e VERSION=0.0.0 -e DB_HOST=localhost -e DB_NAME=dvdrental -e DB_USER=postgres -e DB_PASSWORD=postgres alirezarpi/vault-dynamic-secrets-flask-postgres-app:latest`

### For import sample data into database
`$ wget https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip -O /dvdrental.zip`
`$ unzip /dvdrental.zip`
`$ pg_restore -U postgres -d dvdrental /dvdrental.tar`

----

## URLs

| URL        | What it does               |
| ---------- | -------------------------- |
| `/`        | version + hostname         |
| `/query/`  | version + data             |
| `/health/` | version + state "RUNNING"  |
| `/fail/`   | version + state "SHUTDOWN" |

---

### Quick note

You can change the tag and push it to your *vagrant environment registry* in case where nomad going to use:
```
$ docker tag alirezarpi/vault-dynamic-secrets-flask-postgres-app:latest localhost:5000/vault-dynamic-secrets-flask-postgres-app:latest
$ docker push localhost:5000/vault-dynamic-secrets-flask-postgres-app:latest
```
