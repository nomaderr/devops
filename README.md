# DevOps Demo – FleetDM on GKE

[![CI/CD Status](https://github.com/nomaderr/devops/actions/workflows/deploy.yaml/badge.svg)](https://github.com/nomaderr/devops/actions)

## Target Application

FleetDM was selected as the target application for this demo.

## Deployment Environment

- Initially, the environment was deployed **locally** using **Docker Desktop** with the embedded Kubernetes cluster.
- Later, the deployment was moved to **Google Kubernetes Engine (GKE)** to showcase a real cloud environment setup.

## What Was Done

### Containerization

- The official image `fleetdm/fleet:HEAD` is used.
- It is **re-tagged and published** to GitHub Container Registry (GHCR) using a naming convention:

- The CI pipeline publishes updated images automatically on every push to the `main` branch.

---

### Components and Pods

| Component    | Type        | Description                                |
|--------------|-------------|--------------------------------------------|
| FleetDM      | Deployment  | Main API and web service (`fleet serve`)   |
| MySQL        | Deployment  | Database backend for FleetDM               |
| Redis        | Deployment  | Caching layer                              |
| Ingress      | Ingress     | Exposed via NGINX with TLS (CertManager)   |
| CertManager  | CRD         | For automated TLS certificate provisioning |

---

### Secrets and Configs

- Sensitive environment variables are stored in **Kubernetes Secrets**.
- App-level non-sensitive configs are handled via **ConfigMap** (`fleet-config`).

---

### Networking

- Ingress is configured via **NGINX Ingress Controller**.
- TLS is provided by **CertManager + Buypass Go SSL**.
- Public access is available at:

## CI/CD Pipeline

A full-fledged CI/CD pipeline is implemented using **GitHub Actions**:


## Checks and Best Practices
- Helm linting before each deployment

- Readiness and Liveness probes in deployment.yaml

- Horizontal Pod Autoscaler (HPA) enabled for FleetDM

- InitContainer performs DB preparation (fleet prepare db)

- CI/CD automation with SHA-tagging and GHCR pushes

- ArgoCD Sync enabled for Helm chart reconciliation

## ArgoCD Integration
- ArgoCD is used to synchronize Helm charts.

## Testing & Observability