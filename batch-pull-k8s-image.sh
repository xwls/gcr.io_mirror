#!/bin/sh

# 替换 gcr.io/google-containers/federation-controller-manager-arm64:v1.3.1-beta.1 为真实 image
# 将会把 gcr.io/google-containers/federation-controller-manager-arm64:v1.3.1-beta.1 转换为 xwls/google-containers.federation-controller-manager-arm64:v1.3.1-beta.1 并且会拉取他
# k8s.gcr.io/{image}/{tag} <==> gcr.io/google-containers/{image}/{tag} <==> xwls/google-containers.{image}/{tag}

images=$(cat img.txt)

# 或者 
#images=$(cat <<EOF
# gcr.io/google-containers/federation-controller-manager-arm64:v1.3.1-beta.1
# gcr.io/google-containers/federation-controller-manager-arm64:v1.3.1-beta.1
# gcr.io/google-containers/federation-controller-manager-arm64:v1.3.1-beta.1
#EOF
#)

eval $(echo ${images}|
        sed 's/quay\.io/xwls\/quay/g;s/ghcr\.io/xwls\/ghcr/g;s/registry\.k8s\.io/xwls\/google-containers/g;s/k8s\.gcr\.io/xwls\/google-containers/g;s/gcr\.io/xwls/g;s/\//\./g;s/ /\n/g;s/xwls\./xwls\//g' |
        uniq |
        awk '{print "sudo docker pull "$1";"}'
       )

# 下面这段代码将把本地所有的 xwls 镜像 (例如 xwls/google-containers.federation-controller-manager-arm64:v1.3.1-beta.1 )
# 转换成 grc.io 或者 k8s.gcr.io 的镜像 (例如 gcr.io/google-containers/federation-controller-manager-arm64:v1.3.1-beta.1)
# k8s.gcr.io/{image}/{tag} <==> gcr.io/google-containers/{image}/{tag} <==> xwls/google-containers.{image}/{tag}

for img in $(sudo docker images --format "{{.Repository}}:{{.Tag}}"| grep "xwls"); do
  n=$(echo ${img}| awk -F'[/.:]' '{printf "gcr.io/%s",$2}')
  image=$(echo ${img}| awk -F'[/.:]' '{printf "/%s",$3}')
  tag=$(echo ${img}| awk -F'[:]' '{printf ":%s",$2}')
  sudo docker tag $img "${n}${image}${tag}"
  [[ ${n} == "gcr.io/google-containers" ]] && sudo docker tag $img "k8s.gcr.io${image}${tag}"
  [[ ${n} == "gcr.io/google-containers" ]] && sudo docker tag $img "registry.k8s.io${image}${tag}"
done
