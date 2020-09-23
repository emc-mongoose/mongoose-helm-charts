#!/bin/bash

git stash pop
helm repo index . --url https://emc-mongoose.github.io/mongoose-helm-charts/        # create or update the index.yaml for repo
git add index.yaml *.tgz
git commit index.yaml *.tgz -m "New chart version"
git push
