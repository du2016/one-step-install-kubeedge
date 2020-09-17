#!/bin/bash

echo "install master"

bash ./install-docker.sh
bash ./install-k8s.sh


kubectl patch ds -n kube-system kube-proxy  -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"node-role.kubernetes.io/edge","operator":"DoesNotExist"}]}]}}}}}}}'
iptables -t nat -A OUTPUT -p tcp --dport 10350 -j DNAT --to $MASTER_NODE:10003
sed -i "s/MASTER_NODE/$MASTER_NODE/g" cloudcore/conf/cloudcore.yaml
mkdir /etc/kubeedge
cp cloudcore/conf/cloudcore.yaml /etc/kubeedge
cp cloudcore/cloudcore /usr/local/bin/
cp cloudcore/conf/cloudcore.service /usr/lib/systemd/system/
cp cloudcore/certgen.sh /etc/kubeedge
cd /etc/kubeedge
CLOUDCOREIPS=$$MASTER_NODE bash certgen.sh stream
chmod +x /usr/local/bin/cloudcore
systemctl daemon-reload
systemctl enable cloudcore.service
systemctl start cloudcore



echo "install edgenode"
export TOKEN=`kubectl get secret -nkubeedge tokensecret -o=jsonpath='{.data.tokendata}' | base64 -d`
sed -i "s|token: .*|token: ${TOKEN}|g" edgecore/conf/edgecore.yaml
ssh $EDGE_NODE "mkdir /etc/kubeedge"
sed -i "s/MASTER_NODE/$MASTER_NODE/g" edgecore/conf/edgecore.yaml
sed -i "s/EDGE_NODE/$EDGE_NODE/g" edgecore/conf/edgecore.yaml
scp ./install-docker.sh $EDGE_NODE:/tmp/
ssh $EDGE_NODE "bash /tmp/install-docker.sh && rm -f /tmp/install-docker.sh"
scp ./edgecore/edgecore $EDGE_NODE:/usr/local/bin/
scp ./edgecore/conf/edgecore.service $EDGE_NODE:/usr/lib/systemd/system/
scp ./edgecore/conf/edgecore.yaml $EDGE_NODE:/etc/kubeedge/
scp -r /etc/kubeedge/ca /etc/kubeedge/certs  $EDGE_NODE:/etc/kubeedge/
ssh $EDGE_NODE "chmod +x /usr/local/bin/edgecore"
ssh $EDGE_NODE "systemctl daemon-reload"
ssh $EDGE_NODE "systemctl enable edgecore.service"
ssh $EDGE_NODE "systemctl start edgecore.service"






