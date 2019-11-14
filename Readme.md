# 一键安装kubeedge测试环境

本安装程序基于master进行编译
如需指定版本编译请down完源码，切换到指定版本后执行

```
GOFLAGS="-mod=vendor" make all WHAT=cloudcore
GOFLAGS="-mod=vendor" make all WHAT=edgecore
```

然后将源码目录下`edge/edgecore`,`cloud/cloudcore`拷贝替换本目录下的`edgecore/edgecore`,`cloudcore/cloudcore`

安装了以下组件：

- k8s - 使用kubeadm安装
- edgecore
- cloudcore
- mosquitto

# 环境

- 两台centos7服务器，虚拟机也可以（master 根据kubeadm说明需要2c2g以上、edge node根据官方测试结果，40m内存就能跑起来，应该现有的任何设备都能跑起来）
- master需要免密码登录edge节点，如果拷贝秘钥，请先手动连一次接收指纹
- 关闭iptables和selinux
- 如果重新安装请参考下面的清理操作

# 安装

```
git clone  https://github.com/du2016/one-step-install-kubeedge
MASTER_NODE=主节点的IP EDGE_NODE=边缘节点的IP bash install.sh
```

# 效果

master节点执行

查看节点，可以看到edgenode已经注册成功
```
kubectl get nodes
NAME         STATUS   ROLES    AGE   VERSION
10.10.8.44   Ready    master   28m   v1.16.3
edge-node    Ready    edge     28m   v1.15.3-kubeedge-v1.1.0-beta.0.205+19180d74ccb85c
```

查看应用我们可以看到服务已经运行在edge-node上面
```
kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
nginx-deployment-655748dfb6-zhl96   1/1     Running   0          27m   172.17.0.2   edge-node   <none>           <none>
```

# 清理

## 清理master node

如果需要清理请分别执行以下命令
```
pkill -9 cloudcore
rm -rf /usr/local/cloudcore
rm -rf /etc/kubeedge
kubeadm reset
```

## 清理edge node
```
pkill -9 edgecore
rm -rf /usr/local/edgecore
rm -rf /tmp/install-docker.sh
rm -rf /etc/kubeedge
```


# 污点耐受

安装后默认给edge节点添加了污点（taint）,需要运行在edge上的服务需要通过pod亲和性选择到该节点上面，然后容忍（tolerations）edgenode的污点（taint）

可以参考[默认deploy](./yamls/deploy.yaml)的18-27行


如果有帮助请给个star

欢迎关注我的公众号：

![微信](http://q08i5y6c2.bkt.clouddn.com/qrcode_for_gh_7457c3b1bfab_258.jpg)
