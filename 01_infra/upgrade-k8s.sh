if [ -z "$DESIRED_K8S_VERSION" ] || [ -z "$KUBECONFIG" ] || [ -z "$CONTROL_NODE" ] || [ -z "$TALOS_CONFIG_PATH" ]; then
  echo "Missing required environment variables."
  exit 1
fi

# Get current Kubernetes server version
CURRENT_K8S_VERSION=$(kubectl version | grep "Server Version" | cut -d " " -f 3 | tr -d 'v')

echo "Current Kubernetes version: ${CURRENT_K8S_VERSION}"
echo "Desired Kubernetes version: ${DESIRED_K8S_VERSION}"

# Check if update is needed
if [ "${CURRENT_K8S_VERSION}" = "${DESIRED_K8S_VERSION}" ]; then
  echo "Kubernetes is already at version v${CURRENT_K8S_VERSION}. No update needed."
  exit 0
fi

talosctl --talosconfig $TALOS_CONFIG_PATH -n $CONTROL_NODE upgrade-k8s --from $CURRENT_K8S_VERSION --to $DESIRED_K8S_VERSION