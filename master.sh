set -ex
rm /etc/apt/sources.list
cat > /etc/apt/sources.list << EOF
deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted
deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
deb http://us.archive.ubuntu.com/ubuntu/ xenial universe
deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe
deb http://us.archive.ubuntu.com/ubuntu/ xenial multiverse
deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates multiverse
deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
EOF
export "HTTP_PROXY=http://$proxy_host:$proxy_port"
export "HTTPS_PROXY=http://$proxy_host:$proxy_port"
apt-get update
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get upgrade -y
apt-get install -y docker-ce
apt-get install kubelet kubeadm kubectl -y
mkdir -p /etc/systemd/system/docker.service.d/
if [ "$proxy_host" ]; then
  cat << EOF > /etc/systemd/system/docker.service.d/proxy.conf
[Service]
Environment="HTTP_PROXY=http://$proxy_host:$proxy_port"
Environment="HTTPS_PROXY=http://$proxy_host:$proxy_port"
EOF
fi
systemctl daemon-reload
systemctl restart docker
kubeadm config images pull
unset HTTP_PROXY HTTPS_PROXY
kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config 
export KUBECONFIG=/etc/kubernetes/admin.conf
cd /root
kubeadm token create --print-join-command >> joinslave
kubectl apply -f calico.yaml
python2 webserver.py
