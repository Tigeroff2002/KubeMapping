kubectl delete configmap postgres-migrations -n logistic
kubectl create configmap postgres-migrations --namespace logistic --from-file=postgres/migrations/
kubectl delete deployment postgres -n logistic
kubectl delete pvc postgres-pvc -n logistic
kubectl apply -f postgres/pvc.yaml
kubectl apply -f postgres/deployment.yaml
kubectl logs -f deployment/postgres -n logistic