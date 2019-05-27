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
```

### Using Repo
TODO
```bash
helm add repo ...
helm search ...
helm inspect ...
```
### Manual installation
TODO
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
