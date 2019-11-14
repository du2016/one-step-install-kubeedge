#!/bin/bash

echo "install master"

bash ./install-docker.sh
bash ./install-k8s.sh
cp -r kubeedge-certs /etc/kubeedge

cp -r cloudcore /usr/local/
cd /usr/local/cloudcore
chmod +x cloudcore && nohup ./cloudcore >> /var/log/cloudcore.log 2>&1 &
cd -

echo "install edgenode"
kubectl apply -f edgecore/node.json
kubectl taint nodes edge-node node-role.kubernetes.io/edge=:NoSchedule
sed -i "s/MASTER_NODE/$MASTER_NODE/g" edgecore/conf/edge.yaml
scp ./install-docker.sh $EDGE_NODE:/tmp/
scp -r kubeedge-certs $EDGE_NODE:/etc/kubeedge
scp -r edgecore $EDGE_NODE:/usr/local/

ssh $EDGE_NODE "bash /tmp/install-docker.sh && rm -f /tmp/install-docker.sh"
ssh $EDGE_NODE 'cd /usr/local/edgecore;chmod +x edgecore;nohup ./edgecore &>> /var/log/edgecore.log &'
ssh $EDGE_NODE 'yum install epel* -y && yum install -y mosquitto && mosquitto -d -p 1883'



