# Todo

### flask-postgres-nomad-cluster

- [x] add database url to flask app
- [x] add database cloud configs (nomad)
- [x] use vault dynamic secrets to authenticate for postgres
- [x] add command run at first of postgres (load sample data)

---

### flask-redis-nomad-cluster

- [ ] clone flask-postgres-nomad-cluster and replace postgres with redis but should be scalable
- [ ] use consul service discovery
- [ ] redis dynamic secret