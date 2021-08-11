# flask-postgres-app Example


**NOTE: After each restart you should run `$ vagrant ssh -c "export VAULT_ADDR=http://127.0.0.1:8200 && ./unlock-vault.sh && sudo systemctl restart nomad"`**
## Setup

> Builds related to the apps are located into `README.md` in the `app-configs` directory.

### Creating Static Secret Database Credentials in Vault

After everything is up you can create the database credentials in `vault` by issuing the commands into vagrant box (`$vagrant ssh`):
```
vagrant@test-infrastructure:~$ vault secrets enable -version=1 kv
vagrant@test-infrastructure:~$ vault kv put kv/database user=<USERNAME> password=<PASSWORD>
```

Check if it's issued:
```
vagrant@test-infrastructure:~$ vault kv get kv/database
```

### Creating Database Policy for Nomad

After you created needed credentials in vault you have to create policy (we'll name it `database-access`) in case that `nomad` will use to access the credentials.

`database-policy.hcl`:
```
path "kv/database" {
        capabilities = ["read"]
}
```

now write the policy to the `database-access`:
```
vagrant@test-infrastructure:~$ vault policy write database-access database-policy.hcl
```

### Run the Database Job

You can now run the job deployment to the cluster:
```
$ nomad job run cloud-configs/database.nomad.hcl
```

### Import Sample Data

For continuing this demo project you need sample data the you can import them by doing:
```
$ nomad alloc exec -task postgres-database -job vault-flask-postgres-database wget https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip -O /dvdrental.zip
$ nomad alloc exec -task postgres-database -job vault-flask-postgres-database unzip /dvdrental.zip
$ nomad alloc exec -task postgres-database -job vault-flask-postgres-database pg_restore -U <USER> -W -d dvdrental /dvdrental.tar
```
enter the `password` that you've set on vault and the data is imported successfully (ignore some of queries because it's set to user `postgres` which we're not using).

### Creating Dynamic Secret Database Credentials in Vault 

Enable database secret engine by:
```
vagrant@test-infrastructure:~$ vault secrets enable database
```

then configure how should vault communicate to the DB:
```
vagrant@test-infrastructure:~$ vault write database/config/postgres-database \
    plugin_name=postgresql-database-plugin \
    allowed_roles="postgres-database-role" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/dvdrental?sslmode=disable" \
    username="<USER>" \
    password="<PASSWORD>"
```
> Note that the _<USER>_ and _<PASSWORD>_ are the master credentials that you've created.

then create the _role_ for the database that has limited access to the db:
```
vagrant@test-infrastructure:~$ vault write database/roles/postgres-database-role \
    db_name=postgres-database \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT ALL PRIVILEGES ON TABLE actor TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="2h"
```

### Create Database Policy for the App

`app-policy.hcl`:
```
path "database/creds/postgres-database-role" {
  capabilities = ["read"]
}
```

write the policy to the `database-dynamic-access` so the nomad job use it:
```
vault policy write database-dynamic-access app-policy.hcl
```
### Run the App Job

You can now run the job deployment to the cluster:
```
$ nomad job run cloud-configs/app.nomad.hcl
```

## Accessing the project

Everything is under the **fabio** load balancer and the LB port is `9999`:

| URL        | What it does                               |
| ---------- | ------------------------------------------ |
| `/`        | version + hostname                         |
| `/query/`  | version + data queries from database       |
| `/health/` | version + state "RUNNING"                  |
| `/fail/`   | version + state "SHUTDOWN"                 |

---

**I hope this example was helpful.**