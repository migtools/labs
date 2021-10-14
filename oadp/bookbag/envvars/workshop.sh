#!/bin/sh

# Environment variables to set for the workshop
pushd .
mkdir /tmp/getupdatedoccli
curl https://openshift-release-artifacts.apps.ci.l2s4.p1.openshiftapps.com/4.9.0-rc.8/openshift-client-linux-4.9.0-rc.8.tar.gz -o /tmp/getupdatedoccli/occli.tar.gz
cd /tmp/getupdatedoccli
tar -xvf /tmp/getupdatedoccli/occli.tar.gz
mv oc ~/../bin/oc
popd