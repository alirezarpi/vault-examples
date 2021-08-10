# flask-postgres-app Example


**NOTE: After each restart you should run `$ vagrant ssh -c "export VAULT_ADDR=http://127.0.0.1:8200 && ./unlock-vault.sh"`
## Setup

> Builds related to the apps are located into `README.md` in the `app-configs` directory.

### Creating Database Credentials in Vault

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
$ nomad alloc exec -job vault-flask-postgres-database wget https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip -O /dvdrental.zip
$ nomad alloc exec -job vault-flask-postgres-database unzip /dvdrental.zip
$ nomad alloc exec -job vault-flask-postgres-database pg_restore -U <USER> -W -d dvdrental /dvdrental.tar
```
enter the `password` that you've set on vault and the data is imported successfully (ignore some of queries because it's set to user `postgres` which we're not using).

---

