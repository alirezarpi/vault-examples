# About this repo

## How to setup the cluster

>In this project we used `kind` as our local kubernetes cluster, you can pick your own.

1. Start the cluster

2. Verify cluster
 
`$ kubectl cluster-info --context kind-vlt-k8s`

3. Initial Vault server (dev)

`$ helm install vault hashicorp/vault --set "server.dev.enabled=true" --namespace vltk8s`

4. Enable Kubernetes auth method and Secret engine

```shell
$ kubectl exec --namespace vltk8s -it vault-0 -- vault auth enable kubernetes
$ kubectl exec --namespace vltk8s -it vault-0 -- vault secrets enable -path=kv kv-v2
```

5. Config Kubernetes auth method

```shell
$ kubectl exec --namespace vltk8s -it vault-0 -- sh
(in-container)$ vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

6. Write read policy for kuberenetes

```shell
$ kubectl exec --namespace vltk8s -it vault-0 -- vault policy write vltk8s - <<EOF
path "kv/data/redis/config" {
  capabilities = ["read"]
}
EOF

$ kubectl exec --namespace vltk8s -it vault-0 -- vault policy write vltk8s - <<EOF
path "kv/data/database/config" {
  capabilities = ["read"]
}
EOF

$ kubectl exec --namespace vltk8s -it vault-0 -- vault write auth/kubernetes/role/vltk8s \
    bound_service_account_names=vltk8s-service-acct \
    bound_service_account_namespaces=vltk8s \
    policies=vltk8s \
    ttl=24h
```

7. Create ServiceAccount for Vault access

`$ kubectl create sa vltk8s-service-acct --namespace vltk8s`

## Create KV data for applications

Create DB Secrets:

`$ kubectl exec --namespace vltk8s -it vault-0 -- vault kv put kv/database/config/ POSTGRES_ROOT_PASSWORD="root@1234"`
