# Deploying Mongoose with Helm

Mongoose can be deployed in a kubernetes cluster. Deploy description can be found in the [documentation on the mongoose-base repository](https://github.com/emc-mongoose/mongoose-base/tree/master/doc/deployment#kubernetes).
One of the ways to deploy an application on kubernetes is to use helm.

## About Helm

[Helm](https://helm.sh/docs/) is the package manager for Kubernetes. 

#### Basic terms:

`helm` - client tool running on your workstation

`tiller` - server component running on kubernetes cluster

`charts` - packages

Below are the steps to deploy a mongoose-storage-driver-pravega on kubernetes using the chart.

## Steps to deploy
### Install Helm

>Note: since helm is a kubernetes package manager, kubectl tool must first be installed on the current maschine and a k8s cluster deployed.

Сlient installation.
Get the latest tarball from https://github.com/helm/helm/releases

```bash
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.14.0-linux-amd64.tar.gz
tar -xzf helm-*
sudo mv linux-amd64/helm /usr/local/bin/
```
Next command will install Tiller in the cluster. 
>Note: Tiller is installed by default in the kubectl context cluster. Accordingly, the machine must be switched to the cluster context (see command `kubectl config use-context [cluster-name]` ). Otherwise, you may get errors.
```bash
helm init
```

### Using Repo

To install a chart, you can run the helm `install` command. Helm has several ways to find and install a chart, but the easiest is to use one of the chart registry.

By default helm use `stable/` repo with url: `https://kubernetes-charts.storage.googleapis.com`

Adding our repo:

```bash
helm repo add emc-mongoose https://emc-mongoose.github.io/mongoose-helm-charts/
```
To check chart:
```bash
$ helm search mongoose

NAME                            CHART VERSION   APP VERSION     DESCRIPTION
emc-mongoose/mongoose-pravega   0.1.0           4.2.11          Mongoose is a horizontally scalable and configurable perf...
```
To get more information:
```bash
$ helm inspect chart emc-mongoose/mongoose-pravega

apiVersion: v1
appVersion: 4.2.11
description: Mongoose is a horizontally scalable and configurable performance testing
  utility. This chart contains Mongoose with Praga Storage Driver.
home: https://github.com/emc-mongoose/mongoose-storage-driver-pravega
name: mongoose-pravega
version: 0.1.0
```
To install chart (create kubernetes object defined in a chart):
```bash
helm install --name [chart-name] emc-mongoose/mongoose-pravega [args]
```
or with random chart name
```bash
helm install emc-mongoose/mongoose-pravega [args]
```

### Manual installation

It is also possible to install a chart from source.

```bash
git clone https://github.com/emc-mongoose/mongoose-helm-charts.git
helm install --name [chart-name] mongoose-helm-charts/mongoose-pravega
```

### Remove release

>Note: It is **strongly recommended** to remove the releases with the help of helm. If the release was installed with command `helm install` and will be removed with `kubectl`, it can lead to unexpected behavior.

```bash
helm uninstall [chart-name]
helm del --purge [chart-name]
```

### Parametrisation
TODO
```
helm delete --purge mongoose-pravega
kubectl logs mongoose-pravega
helm install --name mongoose-pravega mongoose-base/kuberenetes/charts/mongoose-pravega/
helm install --name mongoose-pravega mongoose-base/kuberenetes/charts/mongoose-pravega/ --set "load.concurrencyLimit=5"
```

##### List of all params

TODO

# Contributing & Releasing

Ensure all tests are OK
Ensure the new version documentation is ready
Share the testing build with QE and repeat this step until the qualification is OK
Create/replace the corresponding VCS tags:
git tag -d latest
git push origin :refs/tags/latest
git tag -a latest -m <X>.<Y>.<Z>
git push --tags --force
Merge to the release branch (optional)
Wait until the released artifacts appear on Central Maven repo (few tens of minutes usually)
Update the projects depending on the Mongoose's API (storage drivers, etc)
1) change version
```bash
cd mongoose-helm-charts/
git checkout -b gh-pages origin/gh-pages
helm package mongoose-pravega/
cd ..
helm repo index mongoose-helm-charts/ --url https://emc-mongoose.github.io/mongoose-helm-charts/
# helm repo add emc-mongoose https://emc-mongoose.github.io/mongoose-helm-charts/ 
helm repo update
helm install emc-mongoose/mongoose-pravega
```

