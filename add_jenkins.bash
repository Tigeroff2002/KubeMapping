kubectl apply -f jenkins/serviceaccount.yaml
kubectl apply -f jenkins/pvc.yaml
kubectl apply -f jenkins/role.yaml
kubectl apply -f jenkins/rolebinding.yaml
kubectl apply -f jenkins/deployment.yaml
kubectl apply -f jenkins/service.yaml

kubectl port-forward svc/jenkins 8080:8080 -n logistic

kubectl create secret generic docker-hub-credentials \
  --from-literal=username=tigeroff2002 \
  --from-literal=password=Tigeroff@2002 \
  -n logistic \

kubectl create secret generic github-credentials \
  --from-literal=username=Tigeroff2002 \
  --from-literal=password=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 \
  -n logistic \