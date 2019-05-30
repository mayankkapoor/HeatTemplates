set -ex 
# Update source list
rm /etc/apt/sources.list
cat << EOF > /etc/apt/sources.list
deb http://ftp.iitm.ac.in/ubuntu/ xenial main 
deb-src http://ftp.iitm.ac.in/ubuntu/ xenial main 
EOF
export HTTP_PROXY=http://$proxy_host:$proxy_port
export HTTPS_PROXY=http://$proxy_host:$proxy_port
# Install docker
apt-get update && apt-get upgrade -y
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y docker-ce
apt-get install kubelet kubeadm kubectl -y

if [ "$proxy_host" ]; then
  cat << EOF > /etc/systemd/system/docker.service.d/proxy.conf
[Service]
Environment="HTTP_PROXY=http://$proxy_host:$proxy_port"
Environment="HTTPS_PROXY=http://$proxy_host:$proxy_port"
EOF
fi

systemctl daemon-reload

# Download kubeadm images
kubeadm config images pull
# Run kubeadm
cat > /root/kubeadm.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.14.0
controlPlaneEndpoint: $floatingip #VIP
networking:
  podSubnet: 192.168.0.0/16 
EOF
# Unset proxy
unset HTTP_PROXY HTTPS_PROXY
kubeadm init --config /root/kubeadm.yaml
# Copy kubeconfig to ubuntu user
mkdir -p ~ubuntu/.kube
cp /etc/kubernetes/admin.conf ~ubuntu/.kube/config
chown -R ubuntu:ubuntu ~ubuntu/.kube
export KUBECONFIG=/etc/kubernetes/admin.conf
until kubectl get nodes; do
  sleep 2
done
export HTTP_PROXY=http://$proxy_host:$proxy_port
export HTTPS_PROXY=http://$proxy_host:$proxy_port

kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

#kubectl apply -f /root/calico.yaml
#kubectl apply -f /root/tiller.yaml
#docker run --rm mirantisworkloads/kube-binaries:v1.8.7 cat /helm.tar.bz2 | sudo -iu ubuntu tar xvjf -
#cp /root/spinnaker.yaml /home/ubuntu/spinnaker.yaml
#chown ubuntu:ubuntu /home/ubuntu/spinnaker.yaml
