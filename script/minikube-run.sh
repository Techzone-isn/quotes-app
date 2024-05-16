
#!/bin/bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/

# Start Minikube
minikube start

# Enable the ingress controller
minikube addons enable ingress

# Add ingress to the Minikube context
kubectl config set-context --current --add-resource=ingress

# Set up port forwarding across all network interfaces
minikube tunnel --bind-address '*'&

echo "Minikube setup completed."
