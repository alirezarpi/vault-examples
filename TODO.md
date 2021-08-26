# Todo

### the-flask-app

- [x] add database url to flask app
- [x] add database cloud configs (nomad)
- [x] use vault dynamic secrets to authenticate for postgres
- [x] add command run at first of postgres (load sample data)
- [x] use consul service discovery
- [x] ~~use template rendering for dynamic port mapping~~
- [x] use Consul Connect integration 

### the-flask-app-tls
- [ ] copy `the-flask-app` configurations
- [ ] add Vault CA for SSL and TLS connection in Nomad cluster
- [ ] turn off rpc_upgrade_mode and reload nomad on Vagrantfile