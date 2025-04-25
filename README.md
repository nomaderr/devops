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

### Necessary environment variables, configurations, and secrets (e.g., database credentials, API keys) are properly managed via K8s and Github secrets and vars

### Secrets and Configs
- Ci/CD environment variables and secrets are stored in Github.
- Sensitive environment variables are stored in **Kubernetes Secrets**.
- App-level non-sensitive configs are handled via **ConfigMap** (`fleet-config`).

---

### Networking

- Ingress is configured via **NGINX Ingress Controller**.
- TLS is provided by **CertManager + Buypass Go SSL**.
- Public access is available at:
- https://fleet.34.77.188.249.nip.io/login


## Health Checks

The following health probes are defined in the FleetDM deployment for proper readiness and liveness checks:

```yaml
livenessProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /login
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 2
  failureThreshold: 3

```
```
Container: fleet
Liveness Probe: {"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":8080},"timeoutSeconds":1}
Readiness Probe: {"failureThreshold":3,"httpGet":{"path":"/login","port":8080,"scheme":"HTTP"},"initialDelaySeconds":10,"periodSeconds":5,"successThreshold":1,"timeoutSeconds":2}
Ready:          True
ContainersReady: True
```
These checks ensure FleetDM pods are only marked as "Ready" when the UI/API is responsive.

## API Access Example

```
curl -skL -X POST https://fleet.34.77.188.249.nip.io/api/v1/fleet/login \
  -H "Content-Type: application/json" \
  -d '{"email":"email", "password":"yourpassword"}' | jq .
```
```
curl -X GET https://fleet.34.77.188.249.nip.io/api/v1/fleet/spec/enroll_secret \
  -H "Authorization: Bearer <your_token>"
```

## UI Smoke Test
- curl -i https://fleet.34.77.188.249.nip.io/login
```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Strict-Transport-Security: max-age=31536000; includeSubDomains;
...
```
A 200 OK response means the FleetDM web interface is up and responding properly.

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
- https://34.140.38.100/login?return_url=https%3A%2F%2F34.140.38.100%2Fapplications

## Testing & Observability