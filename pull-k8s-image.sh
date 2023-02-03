#!/bin/sh

k8s_img=$1
mirror_img=$(echo ${k8s_img}|
        sed 's/quay\.io/xwls\/quay/g;s/ghcr\.io/xwls\/ghcr/g;s/registry\.k8s\.io/xwls\/google-containers/g;s/k8s\.gcr\.io/xwls\/google-containers/g;s/gcr\.io/xwls/g;s/\//\./g;s/ /\n/g;s/xwls\./xwls\//g' |
        uniq)

if [ -x "$(command -v docker)" ]; then
  sudo docker pull ${mirror_img}
  sudo docker tag ${mirror_img} ${k8s_img}
  exit 0
fi

if [ -x "$(command -v ctr)" ]; then
  sudo ctr -n k8s.io image pull docker.io/${mirror_img}
  sudo ctr -n k8s.io image tag docker.io/${mirror_img} ${k8s_img}
  exit 0
fi

echo "command not found:docker or ctr"
