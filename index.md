### Using Repo

To install a chart, you can run the helm `install` command. Helm has several ways to find and install a chart, but the easiest is to use one of the chart registry.

By default helm use `stable/` repo with url: `https://kubernetes-charts.storage.googleapis.com`

Adding our repo:

```bash
helm repo add emc-mongoose https://emc-mongoose.github.io/mongoose-helm-charts/
```
