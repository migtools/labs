#!/bin/sh

# Environment variables to set for the terminal
pushd .
# Install desired oc client version, from releases https://amd64.ocp.releases.ci.openshift.org/
mkdir /tmp/getupdatedocclient
cd /tmp/getupdatedocclient
curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz -o /tmp/getupdatedocclient/occli.tar.gz
tar -xvf /tmp/getupdatedocclient/occli.tar.gz
mv oc ~/../bin/oc
mv kubectl ~/../bin/kubectl

# # Install velero CLI
# mkdir /tmp/velero-client
# cd /tmp/velero-client
# curl -L https://github.com/vmware-tanzu/velero/releases/download/v1.7.0/velero-v1.7.0-linux-amd64.tar.gz -o /tmp/velero-client/velero-cli.tar.gz
# tar -xvf /tmp/velero-client/velero-cli.tar.gz
# mv velero-v1.7.0-linux-amd64/velero ~/../bin/velero
echo $'alias velero=\'oc exec $(oc get pods -n openshift-adp -o name | grep pod/velero) -c velero -n openshift-adp -- ./velero\'' >> ~/.bash_profile

cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip ~/awscliv2.zip
~/aws/install -i ~/aws-cli

echo "alias aws=~/aws-cli/v2/2.*/bin/aws" >> ~/.bash_profile
echo "alias aws_completer=~/aws-cli/v2/2.*/bin/aws_completer" >> ~/.bash_profile

echo "alias awsocs='aws --endpoint-url http://s3.openshift-storage.svc'" >> ~/.bash_profile
popd