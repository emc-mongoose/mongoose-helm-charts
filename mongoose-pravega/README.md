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
TODO
### Using Repo
TODO
```
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
