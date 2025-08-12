# build mem0 openmemory containers.  
#
# if necessary call this script with the argument --no-cache to have build go through
# the entire Dockerfile...
#

export CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock
case ":$PATH:" in
  *:/usr/local/tmp/nerdctl/bin:*) : ;;  # already in PATH, do nothing
  *) export PATH="$PATH:/usr/local/tmp/nerdctl/bin" ;;
esac

cd openmemory/api
#nerdctl build "$@" -t registry.home:5000/openmemory-mcp-test:latest .
cd ../ui
nerdctl build "$@" -t registry.home:5000/openmemory-ui-test:latest .
cd ../..

if [ $? -ne 0 ]; then
  echo "Build errored out, stopping..."
  exit 1
fi

#nerdctl push --insecure-registry registry.home:5000/openmemory-mcp-test:latest
nerdctl push --insecure-registry registry.home:5000/openmemory-ui-test:latest

read -p "Do you wish to deploy to Kubernetes? (y/N): " x
if [[ "$x" == "y" || "$x" == "Y" ]]; then
  kubectl apply -f openmemory.yaml
fi

read -p "Do you wish to run a system purge? (y/N): " x
if [[ "$x" == "y" || "$x" == "Y" ]]; then
  nerdctl system prune --all --force
fi
