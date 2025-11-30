helm create logistic-chart

helm install logistic ./logistic-chart -n logistic --create-namespace

helm upgrade logistic ./logistic-chart -n logistic

helm uninstall logistic -n logistic

helm list -n logistic