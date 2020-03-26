#!/bin/bash

PROJECT="kcli"
BASE64="base64"
CONFIG=$(cat ~/.kcli/config.yml | $BASE64 -w 0)
ID_RSA_PUB=$(cat ~/.kcli/id_rsa.pub | $BASE64 -w 0)
ID_RSA=$(cat ~/.kcli/id_rsa | $BASE64 -w 0)
oc adm policy add-scc-to-user anyuid system:serviceaccount:$PROJECT:default
oc create secret generic kcli-config-yml --from-file=filename=config.yml
oc annotate secret/kcli-config-yml jenkins.openshift.io/secret.name=kcli-config-yml
oc label secret/kcli-config-yml credential.sync.jenkins.openshift.io=true

oc create secret generic kcli-id-rsa --from-file=filename=~/.ssh/id_rsa
oc annotate secret/kcli-id-rsa jenkins.openshift.io/secret.name=kcli-id-rsa
oc label secret/kcli-id-rsa credential.sync.jenkins.openshift.io=true

oc create secret generic kcli-id-rsa-pub --from-file=filename=$HOME/.ssh/id_rsa.pub
oc annotate secret/kcli-id-rsa-pub jenkins.openshift.io/secret.name=kcli-id-rsa-pub
oc label secret/kcli-id-rsa-pub credential.sync.jenkins.openshift.io=true
