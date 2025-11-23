# Source https://github.com/kasmtech/workspaces-autoscale-startup-scripts/blob/release/1.18.0/docker_agents/ubuntu.sh

#!/bin/bash
set -ex

# Note: Templated items (e.g '<bracket>foo<bracket>') will be replaced by Kasm when provisioning the system
GIVEN_HOSTNAME='{server_hostname}'
GIVEN_FQDN='{server_external_fqdn}'
MANAGER_TOKEN='{manager_token}'
# Ensure the Upstream Auth Address in the Zone is set to an actual DNS name or IP and NOT $request_host$
MANAGER_ADDRESS='{upstream_auth_address}'
SERVER_ID='{server_id}'
PROVIDER_NAME='{provider_name}'
# Swap size in MB, adjust appropriately depending on the size of your Agent VMs
SWAP_SIZE_GB='8'
KASM_BUILD_URL='https://kasm-static-content.s3.amazonaws.com/kasm_release_1.18.0.09f70a.tar.gz'

# Create a swap file
if [[ $(sudo swapon --show) ]]; then
  echo 'Swap Exists'
else
  fallocate -l ${{SWAP_SIZE_GB}}G /var/swap.1
  /sbin/mkswap /var/swap.1
  chmod 600 /var/swap.1
  /sbin/swapon /var/swap.1
  echo '/var/swap.1 swap swap defaults 0 0' | tee -a /etc/fstab
fi


# Default Route IP
sleep 5
IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')

echo "Detected IP Address: $IP" > /tmp/kasm_agent_install.log

if [ -z "$GIVEN_FQDN" ] ||  [ "$GIVEN_FQDN" == "None" ]  ;
then
    AGENT_ADDRESS=$IP
else
    AGENT_ADDRESS=$GIVEN_FQDN
fi

cd /tmp
wget $KASM_BUILD_URL -O kasm.tar.gz
tar -xf kasm.tar.gz

# Install Quemu Agent - Required for Kubevirt environment, optional for others
#apt-get update
#apt install -y qemu-guest-agent
#systemctl enable --now qemu-guest-agent.service

echo "Installing Kasm Agent with the following parameters:" >> /tmp/kasm_agent_install.log
echo "AGENT_ADDRESS: $AGENT_ADDRESS" >> /tmp/kasm_agent_install.log
echo "MANAGER_ADDRESS: $MANAGER_ADDRESS" >> /tmp/kasm_agent_install.log
echo "SERVER_ID: $SERVER_ID" >> /tmp/kasm_agent_install.log
echo "PROVIDER_NAME: $PROVIDER_NAME" >> /tmp/kasm_agent_install.log

bash kasm_release/install.sh -e -S agent -p $AGENT_ADDRESS -m $MANAGER_ADDRESS -i $SERVER_ID -r $PROVIDER_NAME -M $MANAGER_TOKEN

# Cleanup the downloaded and extracted files
rm kasm.tar.gz
rm -rf kasm_release