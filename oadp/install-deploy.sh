pushd .

if oc whoami > /dev/null 2>&1; then
  echo "You are logged in to the OpenShift cluster."
else
  echo "You are not logged in to the OpenShift cluster."
  echo "Please log in to the OpenShift cluster and re-run this script."
  exit 1
fi
ANSIBLE_USER=$(whoami)

# if theses are not set, you won't be prompted again
if [[ -n $CLUSTER_ADMIN_USER ]]; then
    echo "CLUSTER_ADMIN_USER is set to $CLUSTER_ADMIN_USER"
else
    echo "What is cluster admin username? example: kubeadmin or admin"
    read CLUSTER_ADMIN_USER
fi

if [[ -n $STUDENT_PASSWORD ]]; then 
    echo "STUDENT_PASSWORD is set to $STUDENT_PASSWORD"
else
    echo "What is cluster admin password? example: XXXXX-XXXXX-XXXXX-XXXXX"
    read STUDENT_PASSWORD
fi

RAND_TMP_DIR=/tmp/oadp-lab-day-$RANDOM
RAND_VENV_DIR=/tmp/oadp-lab-day-$RANDOM-venv
OCS_NAMESPACE=openshift-storage
echo "Using temp dir $RAND_TMP_DIR"
mkdir $RAND_TMP_DIR
cd $RAND_TMP_DIR
git clone https://github.com/kaovilai/agnosticd --single-branch --branch oadp-5
cd $RAND_TMP_DIR/agnosticd

python3 -m venv $RAND_VENV_DIR
source $RAND_VENV_DIR/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install openshift ansible jmespath

sed -i=.bak 's/hosts: all/hosts: localhost/g' ./ansible/configs/ocp-workloads/ocp-workload.yml
sed -i=.bak 's/k8s_facts/kubernetes.core.k8s_info/g' ./ansible/roles/ocp4-workload-ocs-poc/tasks/workload.yml
sed -i=.bak 's/k8s_facts/kubernetes.core.k8s_info/g' ./ansible/roles/ocp4-workload-ocs-poc/tasks/./pre_workload.yml
# this playbook can error out if it already has namespace openshift-storage. This most likely mean ocs-poc was already successfully run.. and therefore can proceed to next step
ansible-playbook -vvv ./ansible/configs/ocp-workloads/ocp-workload.yml \
-e"ansible_user=${ANSIBLE_USER}" \
-e"ocp_workload=ocp4-workload-ocs-poc" \
-e"silent=False" \
-e"ocs_namespace=${OCS_NAMESPACE}" \
-e"ACTION=create"

# clear openshift-adp namespace to remove old operator if any
echo "Please wait for openshift-adp namespace to delete if there are existing. This can take a while"
oc delete namespace openshift-adp

# install operator
ansible-playbook ./ansible/configs/ocp-workloads/ocp-workload.yml \
-e"ansible_user=${ANSIBLE_USER}" \
-e"ocp_workload=ocp4-workload-oadp" \
-e"silent=False" \
-e"ocs_namespace=${OCS_NAMESPACE}" \
-e"cluster_admin_user=${CLUSTER_ADMIN_USER}" \
-e"student_password=${STUDENT_PASSWORD}" \
-e"ocs_migstorage=true" \
-e"ACTION=create"

rm -rf $RAND_TMP_DIR
rm -rf $RAND_VENV_DIR

popd
