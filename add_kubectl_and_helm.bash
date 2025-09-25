scoop install kubectl

kubectl version --client

mkdir .kube
cd .kube
New-Item config -type file

kubectl cluster-info
kubectl get nodes

scoop install helm