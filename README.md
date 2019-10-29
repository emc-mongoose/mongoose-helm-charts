Table of Contents
=================

   * [Deploying Mongoose with Helm](#deploying-mongoose-with-helm)
      * [About Helm](#about-helm)
         * [Basic terms](#basic-terms)
      * [Steps to deploy](#steps-to-deploy)
         * [Install Helm](#install-helm)
         * [Using Repo](#using-repo)
         * [Manual installation (good for tests)](#manual-installation-good-for-tests)
         * [Remove release](#remove-release)
         * [Parametrisation](#parametrisation)
            * [Custom service type](#custom-service-type)
            * [Custom image](#custom-image)
            * [CLI arguments](#cli-arguments)
            * [List of all params](#list-of-all-params)
         * [Distributed mode](#distributed-mode)
         * [REST API](#rest-api)
            * [Design](#design)
            * [Usage](#usage)
   * [Debugging](#debugging)
     * [Mongoose debugging](#mongoose-debugging)
   * [Releasing](#releasing)

# Deploying Mongoose with Helm

Mongoose can be deployed in a kubernetes cluster. Deploy description can be found in the [documentation on the mongoose-base repository](https://github.com/emc-mongoose/mongoose-base/tree/master/doc/deployment#kubernetes).
One of the ways to deploy an application on kubernetes is to use helm.

## About Helm

[Helm](https://helm.sh/docs/) is the package manager for Kubernetes. 

### Basic terms:

`helm` - client tool running on your workstation

`tiller` - server component running on kubernetes cluster

`charts` - packages

`release` - instance of chart

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

Or update repo:

```bash
helm repo update
```

To check chart:
```bash
$ helm search mongoose

NAME                            CHART VERSION   APP VERSION     DESCRIPTION
emc-mongoose/mongoose   0.1.1           4.2.12          Mongoose is a horizontally scalable and configurable perf...
```
To get more information:
```bash
$ helm inspect chart emc-mongoose/mongoose

apiVersion: v1
appVersion: 4.2.12
description: Mongoose is a horizontally scalable and configurable performance testing
  utility.
home: https://github.com/emc-mongoose/mongoose-storage-driver-pravega
name: mongoose
version: 0.1.1
```
To install chart (create kubernetes object defined in a chart):
```bash
helm install --name [release-name] emc-mongoose/mongoose [args]
```
or with random name
```bash
helm install emc-mongoose/mongoose [args]
```
and you can see list of releases with command:
```bash
$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART                           APP VERSION     NAMESPACE
mongoose        1               Thu Jun 20 13:25:50 2019        DEPLOYED        mongoose-0.1.3                  4.2.12          default
```
### Manual installation (good for tests)

It is also possible to install a chart from source.

```bash
git clone https://github.com/emc-mongoose/mongoose-helm-charts.git
helm install --name [release-name] mongoose-helm-charts/mongoose
```

### Remove release

>Note: It is **strongly recommended** to remove the releases with the help of helm. If the release was installed with command `helm install` and will be removed with `kubectl`, it can lead to unexpected behavior.

```bash
helm del --purge [release-name]
```

### Parametrisation

#### Custom service type
Mongoose service is deployed by default with type LoadBalancer. To specify other service type, use option `service.type`:

```
helm install --name mongoose emc-mongoose/mongoose --set service.type=NodePort ...
```

#### Custom image
By default the chart uses the `mongoose-base` image. To specify a custom image, use the following parameters:

```bash
helm install --name mongoose emc-mongoose/mongoose \
             --set image.name=emcmongoose/mongoose-storage-driver-pravega
```
where `emcmongoose/mongoose-storage-driver-pravega` - name of docker image

#### CLI arguments

To set mongoose CLI arguments use helm argument `--set args=...`:

```bash
helm install --name mongoose \
             emc-mongoose/mongoose \
             --set "args=\"--storage-driver-limit-concurrency=5\"\,\"--load-step-limit-time=60s\"" 
```

Example with custom image:

```bash
helm install --name mongoose \
             emc-mongoose/mongoose \
             --set "args=\"--storage-net-node-addrs=<x.y.z.j>\"\,\"--storage-namespace=scope4\"\,\"--load-step-limit-time=10s\"" \
             --set "image.name=emcmongoose/mongoose-storage-driver-pravega" 
```


#### Custom scenario

Mongoose supports custom scenarios. There are 3 ways to supply the scenario to mongoose:

1. Sending the scenario content via the REST API (mongoose service mode) (see [REST API](#rest-api) )
The option #2 may require external connectivity so the additional option is necessary.

2. Prepare the custom mongoose image containing the scenario which is required need to run. (see [Custom image](#custom-image))

3. Specifying the file via the command line (mongoose interactive mode):

```bash
helm install -n mongoose emc-mongoose/mongoose --set scenario=$(cat <custom_scenario>.js)
```

#### List of all params

To get list of all chart parameters:

```bash
$ helm inspect values emc-mongoose/mongoose
```
As a result, a `values.yaml` is displayed, each of whose parameters can be overridden with `--set <key1.key2.<...>.keyN>=<value>` command.
```bash
########################################################
#### Default values for demo-chart.
########################################################

#### Number of Mongoose replicas to deploy

replicas: 1

#### Since mongoose version 4 there is one image for controller and for peer (driver) nodes
#### The mongoose image configuration

image:
  name: emcmongoose/mongoose-base
  tag: "latest"
  pullPolicy: Always

pod:
  name: mongoose-node

service:
  name: mongoose-svc
  type: LoadBalancer

resources:
  limits:
    cpu: "4"
    memory: "4Gi"
  requests:
    cpu: "4"
    memory: "4Gi"

serviceAccount : ""

debug: false

################## Mongoose CLI args ##################

args: ""

############### Mongoose scenario #####################

scenario: "Load.run();"

```

>Note: about [serviceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

### Distributed mode

As can be seen from the `replicas` parameter, Mongoose by default run in standalone mode with count of node = "1".

To change count of Mongoose node use parametr `--set "replicas=<int>"`
```
helm install --name mongoose emc-mongoose/mongoose --set "replicas=4"
```
Let's see the list of pods
```
NAME                                                 READY   STATUS      RESTARTS   AGE
mongoose                                             0/1     Completed   0          11s
mongoose-node-0                                      1/1     Running     0          11s
mongoose-node-1                                      1/1     Running     0          11s
mongoose-node-2                                      1/1     Running     0          11s
```
It was created pod `mongoose` - this is entry node, and `mongoose-node-<>` - additional nodes.

### REST API

##### Design

![high level design](mongoose-helm-chart.png)

To use mongoose with REST, it is needed to deploy one (standalone mode) or more (distributed mode) nodes with a key `--run-node`. After that, they are waiting for requests. External access is provided through the service (`mongoose-entry-node-svc`). Internal access for internal mongoose-node communication is provided through the service (`mongoose-svc`, ClusterIP type). The node with 0 serial number (`mongoose-node-0`) is selected as the entry node. And the `mongoose-entry-node-svc` communicates with this node, all the requests come to `mongoose-node-0`.

##### Usage

To deploy Mongoose as service (`--run-node`) use `mongoose-service` chart:
```bash
helm install -n mongoose emc-mongoose/mongoose-service --set replicas=3
```

With command `kubectl get -n mongoose pods` you can see inforamtion about running pods (`mongoose-node`). For this example:
```
NAME                                                 READY   STATUS      RESTARTS   AGE
mongoose-node-0                                      1/1     Running     0          11s
mongoose-node-1                                      1/1     Running     0          11s
mongoose-node-2                                      1/1     Running     0          11s
```
With command `kubectl get -n mongoose svc` you can see inforamtion about running service (`mongoose-entry-node-svc`). For this example:

|NAME            |TYPE           |CLUSTER-IP      |EXTERNAL-IP                   |PORT(S)          |AGE
| --- | --- | --- | --- | --- | ---
|mongoose-entry-node-svc   |LoadBalancer   |a.b.c.d   |**x.y.z.j**  |9999:31687/TCP   |25m

By default, the type of service is the `LoadBalancer`, but it can be [changed](#custom-service-type).

To run mongoose scenario it is needed to send HTTP-requests to the external ip **x.y.z.j** [(see Remote API)](doc/interfaces/api/remote). For example:
```
curl -v -X POST http://x.y.z.j:9999/run
```

Example of mongoose `defaults.yaml` for distributed mode:
```
...
load:
  step:
    node:
      addrs:
      - mongoose-node-1.mongoose-svc
      - mongoose-node-2.mongoose-svc
...
```

>REST API doc: https://github.com/emc-mongoose/mongoose-base/tree/master/doc/interfaces/api/remote

# Debugging

```bash
helm template --debug mongoose-helm-charts/mongoose ...
```

See more in the helm docs.

## Mongoose debugging

To debug mongoose use option `debug`. Example: 
```bash
helm install -n mongoose emc-mongoose/mongoose-service --set debug=true ...
```

This option exposes port for mongoose debugging (5005 by default) and run container with `entrypoint_debug.sh`.

[More](https://github.com/emc-mongoose/mongoose-base/tree/master/doc/deployment#debugging)

# Releasing

>Note: `master` branch is used to store charts code, and `gh-pages` branch as charts repository.

0) Ensure that all changes were committed and pushed
1) Ensure that the `version: <X.Y.Z>` is changed in `Chart.yaml` 
2) Ensure the new version documentation is ready
3) Merge to the `master` branch
4) Publish new release in to helm repo (`gh-pages` branch):
```bash
cd $PATH_TO_REPO/mongoose-helm-charts/
helm package $CHART_PATH/               # to build the .tgz file and copy it here
git stash -u                            # save untracked .tgz file
git checkout gh-pages
git stash pop
helm repo index . --url https://emc-mongoose.github.io/mongoose-helm-charts/        # create or update the index.yaml for repo
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
