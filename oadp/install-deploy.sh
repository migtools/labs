pushd .

if oc whoami > /dev/null 2>&1; then
    echo "You are logged in to the OpenShift cluster."
else
    echo "You are not logged in to the OpenShift cluster."
    echo "Please log in to the OpenShift cluster and re-run this script."
    exit 1
fi
ANSIBLE_USER=$(whoami)

# if these are not set, you won't be prompted again
if [[ -n $CLUSTER_ADMIN_USER ]]; then
    echo ""
else
    PS3='Please select the cluster admin user from the choices (1,2,3) above: '
    options=("kubeadmin" "admin" "OTHER")
    select opt in "${options[@]}"
    do
        case $opt in
            "kubeadmin")
                CLUSTER_ADMIN_USER="kubeadmin"
                break
                ;;
            "admin")
                CLUSTER_ADMIN_USER="admin"
                break
                ;;
            "OTHER")
                read -p "Please enter the cluster admin user: " CLUSTER_ADMIN_USER
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
fi
echo "CLUSTER_ADMIN_USER is set to $CLUSTER_ADMIN_USER"

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
python3 -m pip install pipenv
python3 -m pipenv --three
python3 -m pipenv install pip openshift ansible jmespath
git clone https://github.com/redhat-cop/agnosticd.git --single-branch --branch development
cd $RAND_TMP_DIR/agnosticd


sed -i=.bak 's/hosts: all/hosts: localhost/g' ./ansible/configs/ocp-workloads/ocp-workload.yml
sed -i=.bak 's/k8s_facts/kubernetes.core.k8s_info/g' ./ansible/roles/ocp4-workload-ocs-poc/tasks/workload.yml
sed -i=.bak 's/k8s_facts/kubernetes.core.k8s_info/g' ./ansible/roles/ocp4-workload-ocs-poc/tasks/./pre_workload.yml

ocs_mcg_pv_pool_bucket_name="migstorage"

MCG_PHASE=$(oc get obc $ocs_mcg_pv_pool_bucket_name -n openshift-storage -ojsonpath=‘{.status.phase}’)
if [[ $MCG_PHASE == *"Bound"* ]]; then
    echo "MCG is already deployed"
else
    echo "Deploying MCG"
    python3 -m pipenv run ansible-playbook ./ansible/configs/ocp-workloads/ocp-workload.yml \
    -e"ansible_user=${ANSIBLE_USER}" \
    -e"ocp_workload=ocp4-workload-ocs-poc" \
    -e"silent=False" \
    -e"ocs_namespace=${OCS_NAMESPACE}" \
    -e"ocs_mcg_pv_pool_bucket_name=${ocs_mcg_pv_pool_bucket_name}" \
    -e"ACTION=create"
fi

# clear openshift-adp namespace to remove old operator if any
echo "Please wait for openshift-adp namespace to delete if there are existing. This can take a while"
oc delete namespace openshift-adp

# install operator
python3 -m pipenv run ansible-playbook ./ansible/configs/ocp-workloads/ocp-workload.yml \
-e"ansible_user=${ANSIBLE_USER}" \
-e"ocp_workload=ocp4-workload-oadp" \
-e"silent=False" \
-e"ocs_namespace=${OCS_NAMESPACE}" \
-e"cluster_admin_user=${CLUSTER_ADMIN_USER}" \
-e"student_password=${STUDENT_PASSWORD}" \
-e"ocs_migstorage=true" \
-e"ocs_mcg_pv_pool_bucket_name=${ocs_mcg_pv_pool_bucket_name}" \
-e"bookbag_repo=https://github.com/hhpatel/labs.git" \
-e"oadp_operator_subscription_release=v1.1.3" \
-e"ACTION=create"
python3 -m pipenv --rm
rm -rf $RAND_TMP_DIR
rm -rf $RAND_VENV_DIR

popd
