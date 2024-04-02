# Base Kubernetes Development Environment (base-k8s-dev-env)

## Overview

This project, named "base-k8s-dev-env", aims to provide a foundation for setting up a Kubernetes development environment using Minikube. It includes functionalities to install ArgoCD and Crossplane, configure repositories, and manage applications within the Kubernetes cluster.

## Pre-requirements

Before proceeding with the actions defined in the Makefile, ensure you have the following pre-requisites set up:

- [**Minikube**](https://minikube.sigs.k8s.io/docs/start/): Make sure [Minikube](https://minikube.sigs.k8s.io/docs/start/) is installed on your system and configured properly.
- [**kubectl**](https://kubernetes.io/docs/tasks/tools/): Ensure `kubectl`, the Kubernetes command-line tool, is installed and configured to communicate with your Minikube cluster.
- [**Helm**](https://helm.sh/docs/intro/install/): Helm, the package manager for Kubernetes, should be installed.
- **VirtualBox (if using VirtualBox driver)**: If you're using the VirtualBox driver for Minikube, ensure VirtualBox is installed on your system.

## Makefile Actions

### 1. argocd-install

This action installs ArgoCD into the Minikube cluster.

### 2. argocd-waiting

Waits for any pod in the ArgoCD namespace to be ready.

### 3. argocd-print-url

Prints the URL to access the ArgoCD server running in the Minikube cluster.

### 4. argocd-print-password

Prints the password to log in to the ArgoCD UI. This action decodes the password from the Kubernetes secret.

### 5. argocd-port-forward

Port forwards the ArgoCD server to localhost for local access. That also will print the password the admin user:

```bash
make argocd-port-forward
kubectl --namespace argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo 
M9-z53G58-liaTfi
kubectl port-forward --namespace argocd svc/argocd-server 8080:443
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

> Only necessary if you are not using ingress

### 6. argocd-login

Logs in to the ArgoCD server using the admin credentials.

### 7. argocd-open-ui

Opens the ArgoCD UI in the default web browser.

### 8. argocd-clean

Cleans up the ArgoCD installation by deleting the resources and namespace.

### 9. crossplane-configure-repo

Configures the Crossplane Helm repository in ArgoCD.

### 10. crossplane-install

Installs Crossplane into the Kubernetes cluster using ArgoCD.

### 11. crossplane-clean

Cleans up the Crossplane and ArgoCD installations by deleting the Crossplane application and repository configuration.

### 12. minikube-start

Starts the Minikube cluster with specified resources.

### 13. server-start

Starts enviroment

### 14. server-stop

Cleans up the Minikube cluster by deleting it.

### 15. minikube-delete

Deletes the Minikube cluster.

## Usage

1. Ensure the pre-requisites are met.
2. Clone the repository containing the Makefile.
3. Run `make <action>` to perform the desired action, where `<action>` is one of the actions defined in the Makefile.

## Note

- Make sure to update any URLs or configurations in the Makefile according to your environment and requirements.
- Be cautious while executing actions that involve deleting resources, as they might result in data loss or disruption of services.
