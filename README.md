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

Get the latest tarball from https://github.com/helm/helm/releases

```bash
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.14.0-linux-amd64.tar.gz
tar -xzf helm-*
cp linux-amd64/helm /usr/local/bin/helm
helm init
```

### Using Repo
TODO
```bash
helm add repo emc-mongoose https://emc-mongoose.github.io/helm/
```
To check chart:
```bash
$ helm search mongoose

NAME                            CHART VERSION   APP VERSION     DESCRIPTION
emc-mongoose/mongoose-pravega   0.0.1-beta      4.2.11          Mongoose is a horizontally scalable and configu...
```
To get more information:
```bash
$ helm inspect chart mongoose-pravega

apiVersion: v1
appVersion: 4.2.11
description: Mongoose is a horizontally scalable and configurable performance testing
  utility. This chart contains Mongoose with Praga Storage Driver.
home: https://github.com/emc-mongoose/mongoose-storage-driver-pravega
icon: https://avatars0.githubusercontent.com/u/12926680
maintainers:
- name: Dell EMC
  url: http://dellemc.com
name: mongoose-pravega
version: 0.0.1-beta
```
To install chart (create pod):
```bash
helm install [pod-name] mongoose-pravega [args]
```

### Manual installation

It is also possible to install a chart from source.

```bash
git clone https://github.com/emc-mongoose/helm.git
helm install [pod-name] helm/mongoose-pravega
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

