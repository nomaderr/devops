# DevOps Demo – FleetDM on GKE

[![CI/CD Status](https://github.com/nomaderr/devops/actions/workflows/deploy.yaml/badge.svg)](https://github.com/nomaderr/devops/actions)

## Target Application

FleetDM was selected as the target application for this demo.
Here in K8s foler you can find both Helm chart template and manifests for bare metal setup

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
```
NAME                                         READY   STATUS    RESTARTS   AGE
pod/fleet-fleet-7cbfb4b977-j4d2x             1/1     Running   0          84s
pod/mysql-57b6ccb56c-kqntx                   1/1     Running   0          27h
pod/nginx-default-backend-7866b8546d-78njn   1/1     Running   0          18h
pod/redis-9787f47cf-jk4gs                    1/1     Running   0          27h

NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/fleet                   ClusterIP   34.118.236.148   <none>        80/TCP     27h
service/mysql                   ClusterIP   34.118.239.90    <none>        3306/TCP   27h
service/nginx-default-backend   ClusterIP   34.118.231.12    <none>        80/TCP     18h
service/redis                   ClusterIP   34.118.233.108   <none>        6379/TCP   27h

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/fleet-fleet             1/1     1            1           27h
deployment.apps/mysql                   1/1     1            1           27h
deployment.apps/nginx-default-backend   1/1     1            1           18h
deployment.apps/redis                   1/1     1            1           27h

NAME                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/fleet-fleet-555fd78557             0         0         0       3h15m
replicaset.apps/fleet-fleet-58b6fcdbbf             0         0         0       105m
replicaset.apps/fleet-fleet-5dc9fbd84d             0         0         0       138m
replicaset.apps/fleet-fleet-5f449fcd5              0         0         0       100m
replicaset.apps/fleet-fleet-66498c8f49             0         0         0       22m
replicaset.apps/fleet-fleet-67dcd8dd65             0         0         0       107m
replicaset.apps/fleet-fleet-68fff4454f             0         0         0       142m
replicaset.apps/fleet-fleet-69fd747dbb             0         0         0       125m
replicaset.apps/fleet-fleet-6bfdc89bf8             0         0         0       140m
replicaset.apps/fleet-fleet-7cbfb4b977             1         1         1       85s
replicaset.apps/fleet-fleet-84d4d46cd8             0         0         0       135m
replicaset.apps/mysql-57b6ccb56c                   1         1         1       27h
replicaset.apps/nginx-default-backend-7866b8546d   1         1         1       18h
replicaset.apps/redis-9787f47cf                    1         1         1       27h

NAME                                              REFERENCE                TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/fleet-fleet   Deployment/fleet-fleet   cpu: 2%/60%   1         3         1          25h
```

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
---

## Checks and Best Practices
```
https://github.com/nomaderr/devops/actions
```
- Helm linting before each deployment

- Readiness and Liveness probes in deployment.yaml

- Horizontal Pod Autoscaler (HPA) enabled for FleetDM

- InitContainer performs DB preparation (fleet prepare db)

- CI/CD automation with SHA-tagging and GHCR pushes

- ArgoCD Sync enabled for Helm chart reconciliation

## ArgoCD Integration
- ArgoCD is used to synchronize Helm charts.
- https://34.140.38.100/login?return_url=https%3A%2F%2F34.140.38.100%2Fapplications
![ArgoCD](k8s/images/fleet.jpg)
---
## Testing & Observability
- Smoke test included in pipeline and integrationTest.sh present in scipts folder


## Quick Start
- Deploy your K8s cluster
```
git clone https://github.com/your-username/devops.git
cd devops
```
- Install cert-manager (optional but recommended)
- Create fleet namespace
- Install the Helm chart(dev.yaml) for fleet env