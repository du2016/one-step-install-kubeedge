cd k8s-pkg
yum install  -y kubeadm-1.16.3-0.x86_64.rpm       kubectl-1.16.3-0.x86_64.rpm       kubelet-1.16.3-0.x86_64.rpm       kubernetes-cni-0.7.5-0.x86_64.rpm
cd -
systemctl enable --now kubelet
sed -i "s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward =1/g" /etc/sysctl.conf
sed -i "s/net.bridge.bridge-nf-call-iptables = 0/net.bridge.bridge-nf-call-iptables =1/g" /etc/sysctl.conf
sed -i "s/net.bridge.bridge-nf-call-ip6tables = 0/net.bridge.bridge-nf-call-ip6tables =1/g" /etc/sysctl.conf
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/ipv4/ip_forward
modprobe br_netfilter
swapoff -a
rm -rf /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
kubeadm init --image-repository="registry.aliyuncs.com/google_containers" --kubernetes-version="v1.16.0" --node-name="$MASTER_NODE" --pod-network-cidr="200.1.0.0/16" --service-cidr="200.2.0.0/16"
mkdir /root/.kube/
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f yamls