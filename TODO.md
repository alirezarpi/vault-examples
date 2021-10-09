# Todo

### the-flask-app

- [x] add database url to flask app
- [x] add database cloud configs (nomad)
- [x] use vault dynamic secrets to authenticate for postgres
- [x] add command run at first of postgres (load sample data)
- [x] use consul service discovery
- [x] ~~use template rendering for dynamic port mapping~~
- [x] use Consul Connect integration 
- [ ] refactor and beautify Vagrantfile

### the-flask-app-tls
- [x] copy `the-flask-app` configurations
- [x] add Vault CA for SSL and TLS connection in Nomad cluster
- [x] turn off rpc_upgrade_mode and reload nomad on Vagrantfile
- [x] make everything runnable
- [x] rotate gossip encryption for consul
- [ ] refactor and beautify Vagrantfile

### docker swarm mode example
- [x] create docker-compose.yml
- [x] create swarm cluster
- [x] add docker secrets to static docker-compose
- [ ] complete readme
- [ ] application read password from file, or is there any way to not do that ?
- [ ] add dynamic secrets for `the-flask-app` inside Vault
- [ ] add static secrets for `the-flask-database` inside Vault

### kubernetes mode example
