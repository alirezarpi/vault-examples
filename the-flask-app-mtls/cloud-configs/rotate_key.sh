#!/usr/bin/env bash

export CONSUL_HTTP_ADDR="http://localhost:8500"
NEW_KEY=`cat /opt/consul/gossip/gossip.key | sed -e "/^$/d"`
consul keyring -install $NEW_KEY
consul keyring -use $NEW_KEY
KEYS=`curl -s $CONSUL_HTTP_ADDR/v1/operator/keyring`
ALL_KEYS=`echo $KEYS | jq -r '.[].Keys| to_entries[].key' | sort | uniq`
for i in `echo $ALL_KEYS`; do
  if [ $i != $NEW_KEY ] ; then
    consul keyring -remove $i
  fi
done
