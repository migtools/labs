#!/bin/sh

# Environment variables to set for the workshop
pushd .
# Install desired oc client version, from releases https://amd64.ocp.releases.ci.openshift.org/
mkdir /tmp/getupdatedocclient
curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz -o /tmp/getupdatedocclient/occli.tar.gz
cd /tmp/getupdatedocclient
tar -xvf /tmp/getupdatedocclient/occli.tar.gz
mv oc ~/../bin/oc
mv kubectl ~/../bin/kubectl
popd