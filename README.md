# Simple Flask Application

This example demonstrates how to set up a simple Flask application with five endpoints. As you generate traffic to these endpoints, you can view the output from the `/http_data` endpoint and monitor metrics through Prometheus.

## Deployment Instructions

Follow these steps to run the application on Minikube:

### 1. Install Minikube and kubectx

- **Download Minikube:** Visit the [Minikube Installation Guide](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download) to get Minikube for your environment.
- **Install `kubectx`:** This tool simplifies context and namespace switching in Kubernetes. You can find it on [GitHub - kubectx](https://github.com/ahmetb/kubectx).

### 2. Start Minikube

Run the following command to start Minikube:

```bash
minikube start
```

## Build or Use a Docker Image
You can either build your own Docker image or use a prebuilt one. To build an image directly in Minikube, execute:

```bash
# Configure your shell to use Minikube's Docker daemon
eval $(minikube docker-env)
cd app
docker build -t custom-prometheus-flask-exporter .
```

## Deploy Prometheus with NGINX
Run the following commands to set up Prometheus and NGINX:
```bash
# Switch to the Minikube Kubernetes context
kubectx minikube

# Create a monitoring namespace
kubectl create namespace monitoring && kubens $_

# Generate htpasswd for authentication
htpasswd -c auth admin

# Create a Kubernetes secret for NGINX authentication
kubectl create secret generic prometheus-nginx-htpasswd --from-file=auth -n monitoring

# Add Helm repositories for Prometheus and NGINX
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Deploy Prometheus using Helm
helm upgrade --install prometheus prometheus --values prometheus/memory-alerts.yaml --values prometheus/values/values.yaml -n monitoring

# Access Prometheus via NGINX
kubectl get pods -n monitoring
NGINX="prometheus-ingress-nginx-controller-fd5c64db8-c4z6f" # Example pod name
kubectl port-forward $NGINX 8080:80 &
# Open a browser and navigate to:
http://localhost:8080 # prometheus
http://localhost:8080/alertmanager # alertmanager
```

## Deploy the Flask Application
Now, set up the Flask application:

**Note:** If you prefer to use a prebuilt image, set the image to `sg110/custom-prometheus-flask-exporter` and comment out the line `imagePullPolicy: Never` in the `app.yaml` file.

```bash
# Create a Flask namespace
kubectl create namespace flask && kubens $_

# Deploy the Flask app (modify the image if using a prebuilt one)
helm upgrade --install flask flask -n flask

# Access the Flask application
kubectl get pods -n flask
FLASK="prometheus-flask-exporter-f6956d6b5-ww5xf" # Example pod name
kubectl port-forward $FLASK 5000:5000 &
# Open a browser and access the following endpoints:
# http://localhost:5000/index
# http://localhost:5000/action
# http://localhost:5000/error_endpoint
# http://localhost:5000/client_error_endpoint
# http://localhost:5000/http_data
# http://localhost:5000/metrics

# To send requests to each endpoint, run:
chmod +x load-test.sh
./load-test.sh
```

## View Custom Metrics in Prometheus
In Prometheus, you can monitor the following custom metrics:
```bash
http_requests_total
http_requests_400_total
http_requests_500_total
```