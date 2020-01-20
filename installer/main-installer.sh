#!/bin/bash
# Main installer script

base_dir=~/
digi_dir=${base_dir}digikube/
digi_ops_executer=${digi_dir}cluster/digiops

kubectl_installer=${digi_dir}installer/kubectl-installer.sh
${kubectl_installer}

kops_installer=${digi_dir}installer/kops-installer.sh
${kops_installer}

kopsp_installer=${digi_dir}installer/kopsp-installer.sh
${kopsp_installer}

#cluster_installer=${digi_dir}cluster/cluster-installer.sh
#${cluster_installer}

. ${digi_ops_executer}
create-cluster
