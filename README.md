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
emc-mongoose/mongoose   0.1.0           4.2.11          Mongoose is a horizontally scalable and configurable perf...
```
To get more information:
```bash
$ helm inspect chart emc-mongoose/mongoose

apiVersion: v1
appVersion: 4.2.11
description: Mongoose is a horizontally scalable and configurable performance testing
  utility.
home: https://github.com/emc-mongoose/mongoose-storage-driver-pravega
name: mongoose
version: 0.1.0
```
To install chart (create kubernetes object defined in a chart):
```bash
helm install --name [chart-name] emc-mongoose/mongoose [args]
```
or with random chart name
```bash
helm install emc-mongoose/mongoose [args]
```

### Manual installation (good for tests)

It is also possible to install a chart from source.

```bash
git clone https://github.com/emc-mongoose/mongoose-helm-charts.git
helm install --name [chart-name] mongoose-helm-charts/mongoose
```

### Remove release

>Note: It is **strongly recommended** to remove the releases with the help of helm. If the release was installed with command `helm install` and will be removed with `kubectl`, it can lead to unexpected behavior.

```bash
helm del --purge [chart-name]
```

### Parametrisation

#### Custom image
By default the chart uses the `mongoose-base` image. To specify a custom image, use the following parameters:

```bash
helm install --name mongoose emc-mongoose/mongoose \
             --set image.name=emcmongoose/mongoose-pravega-driver
```

#### CLI arguments

**TODO**

```bash
helm install --name mongoose emc-mongoose/mongoose \
             --set args=[--load-step-limit-time=60s,--storage-driver-limit-concurrency=5]
```

#### List of all params

**TODO**
```bash
$ helm inspect values emc-mongoose/mongoose
```
As a result, a `values.yaml` is displayed, each of whose parameters can be overridden with `--set <key1.key2.<...>.keyn>=<value>` command.
```bash
# Default values for demo-chart.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# Number of driver replicas to deploy
replicas: 3

# Since mongoose version 4 there is one image for controller and for peer (driver) nodes
# The mongoose image configuration
image:
  name: emcmongoose/mongoose-base
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  name: mongoose-node

resources:
  limits:
    cpu: "4"
    memory: "4Gi"
  requests:
    cpu: "4"
    memory: "4Gi"

#####################
# Mongoose CLI args #
#####################
args: ""

```


# Releasing

>Note: `master` branch is used to store charts code, and `gh-pages` branch as charts repository.

1) Ensure that the `version: <X.Y.Z>` is changed in `Chart.yaml` 
2) Ensure the new version documentation is ready
3) Merge to the `master` branch
4) Publish new release in to helm repo (`gh-pages` branch):
```bash
cd $PATH_TO_REPO/mongoose-helm-charts/
helm package $CHART_PATH/ # to build the .tgz file and copy it here
git stash -u # save untracked .tgz file
git checkout gh-pages
git stash pop
helm repo index . --url https://emc-mongoose.github.io/mongoose-helm-charts/ # create or update the index.yaml for repo
git add index.yaml *.tgz
git commit -m 'New chart version'
git push

# helm repo add $REPO_NAME https://emc-mongoose.github.io/mongoose-helm-charts/ 
helm repo update
helm install $REPO_NAME/$CHART_NAME
```
>For example: 
>* REPO_NAME=emc-mongoose
>* CHART_NAME=mongoose
>* CHART_PATH=$CHART_NAME/