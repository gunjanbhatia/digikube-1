#!/bin/sh

export CLOUD_TYPE="gce"

export CLOUD_REGION="us-central1"
export CLOUD_ZONE="us-central1-c"

echo
echo
echo "Removing cloud environemnt for DigiKube.  Cloud provider: gce."
echo

##########################################################
#Get cloud project details
export CLOUD_PROJECT="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
if [ $? -gt 0 ]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
fi
if [ -z ${CLOUD_PROJECT} ]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
else
	echo "Deleting DigiKube resources from cloud project.  Cloud project id: ${CLOUD_PROJECT}."
fi

##########################################################
#Delete the Bastion Host for DigiKube
echo "Attempting to delete bastion host for Digikube.  Bastion host name: ${BASTION_HOST_NAME}."
export BASTION_HOST_NAME="bastion-host-01"
export BASTION_HOST_ZONE=$(gcloud compute instances list --filter="name=${BASTION_HOST_NAME}" --format="value(zone)")
if [ $? -gt 0 ]; then
	echo "Unable to get the bastion host or its zone details.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
fi
if [ -z ${BASTION_HOST_ZONE} ]; then
	echo "Unable to get the bastion host or its zone details.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
else
	echo "Deleting bastion host in zone: ${BASTION_HOST_ZONE}."
fi
if [ -z $(gcloud compute instances list --filter="name=${BASTION_HOST_NAME}" --format="value(name)") ]; then
  echo "No bastion host available with the name ${BASTION_HOST_NAME}.  Skipping bastion host deletion."
else
  gcloud --quiet compute instances delete ${BASTION_HOST_NAME} --zone=${BASTION_HOST_ZONE}
  if [ $? -gt 0 ]; then
    #Unknown error while deleting the bastion host.
    echo "Unable to delete bastion host for DigiKube.  Exiting the DigiKube delete."
    echo "Manually review and delete DigiKube cloud resources."
    exit 1
  else
    echo "Deleted the bastion host: ${BASTION_HOST_NAME}."
  fi
fi

###########################################################
#Delete firewall rule for bastion host
export CLOUD_SUBNET="${CLOUD_PROJECT}-vpc"
export BASTION_HOST_FIREWALL_RULE_NAME="${CLOUD_SUBNET}-allow-bastion-ssh"
echo "Attempting to delete firewall rule for bastion host: ${BASTION_HOST_FIREWALL_RULE_NAME}"
if [ -z $(gcloud compute firewall-rules list --filter=name=${BASTION_HOST_FIREWALL_RULE_NAME} --format="value(name)") ]; then
	echo "No firewall rule available with the name ${BASTION_HOST_FIREWALL_RULE_NAME}.  Skipping firewall rule deletion."
else
	gcloud -q compute firewall-rules delete ${BASTION_HOST_FIREWALL_RULE_NAME}
	if [ $? -gt 0 ]; then
    		#Unknown error while deleting the firewall rule.
    		echo "Unable to delete firewall rule for bastion host.  Exiting the DigiKube delete."
    		echo "Manually review and delete DigiKube cloud resources."
    		exit 1
  	else
    		echo "Deleted the firewall rule for bastion host: ${BASTION_HOST_FIREWALL_RULE_NAME}."
	fi
fi

###########################################################
#Delete the network for DigiKube
echo "Attempting to delete network for Digikube.  Network name: ${CLOUD_SUBNET}."
if [ -z $(gcloud compute networks list --filter=name=${CLOUD_SUBNET} --format="value(name)") ]; then
  echo "No network available with the name ${CLOUD_SUBNET}.  Skipping network deletion."
else
  gcloud --quiet compute networks delete ${CLOUD_SUBNET}
  if [ $? -gt 0 ]; then
    #Unknown error while deleting the network.
    echo "Unable to delete network for DigiKube.  Exiting the DigiKube delete."
    echo "Manually review and delete DigiKube cloud resources."
    exit 1
  else
    echo "Deleted the network ${CLOUD_SUBNET}."
  fi
fi
