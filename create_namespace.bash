kubectl apply -f namespace.yaml

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx

kubectl create configmap postgres-migrations --namespace logistic --from-file=postgres/migrations/
kubectl apply -f postgres/secrets.yaml 
kubectl apply -f postgres/pvc.yaml 
kubectl apply -f postgres/deployment.yaml
kubectl apply -f postgres/service.yaml

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.2/cert-manager.yaml
kubectl apply -f cluster-issuer.yaml

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=logistic-api/O=logistic-api"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=logistic-client/O=logistic-client"
kubectl create secret tls tls-secret --cert=./tls.crt --key=./tls.key -n logistic

kubectl apply -f api/deployment.yaml
kubectl apply -f api/service.yaml 
kubectl apply -f ingress.yaml
kubectl apply -f ingress-api-test.yaml

kubectl apply -f web/deployment.yaml
kubectl apply -f web/service.yaml 
kubectl apply -f ingress-client.yaml

kubectl apply -f nginx/configmap.yaml 
kubectl apply -f nginx/deployment.yaml  
kubectl apply -f nginx/service.yaml

kubectl apply -f builder/deployment.yaml
kubectl apply -f builder/service.yaml 

kubectl apply -f payment/deployment.yaml
kubectl apply -f payment/service.yaml 

kubectl get pods -n logistic