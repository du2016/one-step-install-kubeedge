
yum install yum-utils device-mapper-persistent-data lvm2 -y

yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo -y

yum install docker-ce-18.06.2.ce -y

mkdir /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF


mkdir -p /etc/systemd/system/docker.service.d

systemctl enable docker.service
systemctl daemon-reload
systemctl restart docker