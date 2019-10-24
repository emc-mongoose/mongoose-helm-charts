#!/bin/bash

helm repo index . --url https://emc-mongoose.github.io/mongoose-helm-charts/        # create or update the index.yaml for repo
git add index.yaml *.tgz

