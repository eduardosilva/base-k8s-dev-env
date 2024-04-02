# Define variables
## ARGO
ARGOCD_NAMESPACE := argocd
ARGOCD_MANIFEST_URL := https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml  

## CROSSPLANE
CROSSPLANE_NAMESPACE := crossplane-system
CROSSPLANE_REPO_NAME := crossplane-stable
CROSSPLANE_REPO_URL := https://charts.crossplane.io/stable

## KOMODORIO
KOMODORIO_REPO_URL := https://helm-charts.komodor.io

## WEBHOOK FOLDER
HELM_CHART_FOLDER := information-collector-webhook

# Install ArgoCD in Minikube
argocd-install:
	@echo "Installing ArgoCD"
	kubectl create namespace $(ARGOCD_NAMESPACE)
	kubectl apply --namespace $(ARGOCD_NAMESPACE) --filename $(ARGOCD_MANIFEST_URL)
	kubectl apply --namespace $(ARGOCD_NAMESPACE) --filename ./config/argocd-server-nodeport.yaml

argocd-waiting:
	@echo "Waiting for any pod in ArgoCD namespace to be ready..."
	@sleep 120s

argocd-print-url:
	minikube service --namespace $(ARGOCD_NAMESPACE)  argocd-server-nodeport --url

argocd-print-password:
	kubectl --namespace $(ARGOCD_NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo 

# Port forward the ArgoCD server
argocd-port-forward: argocd-print-password
	kubectl port-forward --namespace $(ARGOCD_NAMESPACE) svc/argocd-server 8080:443

# Authenticate with ArgoCD
argocd-login: 
	argocd login $$(minikube service --namespace $(ARGOCD_NAMESPACE) argocd-server-nodeport --url | sed 's/http:\/\///') --insecure --username admin --password $$(kubectl --namespace $(ARGOCD_NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)

# Open the ArgoCD UI in the web browser
argocd-open-ui:
	minikube service --namespace $(ARGOCD_NAMESPACE) argocd-server

# Clean up ArgoCD installation
argocd-clean:
	kubectl delete --namespace $(ARGOCD_NAMESPACE) --filename $(ARGOCD_MANIFEST_URL)
	kubectl delete namespace $(ARGOCD_NAMESPACE)

# Configure the ArgoCD repository
crossplane-configure-repo: argocd-login
	argocd repo add $(CROSSPLANE_REPO_URL) --type helm --name $(CROSSPLANE_REPO_NAME)

# Create an ArgoCD Application for Crossplane
crossplane-install: crossplane-configure-repo
	kubectl apply --filename config/crossplane-app.yaml
	@sleep 60s
	kubectl apply --filename config/controllerconfig.yaml

# Clean up Crossplane and ArgoCD installations
crossplane-clean:
	argocd repo rm $(CROSSPLANE_REPO_URL)  
	kubectl delete --filename config/controllerconfig.yaml 
	kubectl delete --filename config/crossplane-app.yaml

minikube-start:
	# using virtualbox driver with vpn
	# minikube start --memory=5120 --cpus=4 --vm-driver=virtualbox

	 minikube start --memory=5120 --cpus=4 
	 
minikube-install-addons:
	 minikube addons enable ingress

server-start: minikube-start minikube-install-addons argocd-install

server-stop: minikube-delete

minikube-delete: 
	minikube delete

.PHONY: argocd-install argocd-waiting argocd-print-url argocd-print-password argocd-port-forward argocd-login argocd-open-ui argocd-clean crossplane-configure-repo crossplane-install crossplane-clean minikube-start server-start server-stop minikube-delete minikube-install-addons
