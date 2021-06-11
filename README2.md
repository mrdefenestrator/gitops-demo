# filewcount in Kubernetes

## Environment

- `GITHUB_TOKEN` is a GitHub Access Token with git repo read/write permissions
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Setting Up

- bootstrapping

## Monitoring Workload

- metrics
- logs
- events

## Upgrading Workload

- gitops

## Work Remaining

- Implement Semantic-Release to automatically version in pipeline so that releases of filewcount could be deployed to other Kubernetes clusters

### Security

- Implement linting and resource scanning of K8s manifests in CI pipeline
- Update credentials for Grafana to use non-default
- Implement TLS ingress and cert-manager for auto-provisioning of certificates

### Infrastructure

- Demonstrate bootstrapping to AWS EKS cluster rather than just Kind
- Demonstrate ingress controller binding to AWS ELB

### Monitoring

- Implement readiness and liveness probes for filewcount workload
- Implement log scraping any analysis (elastic stack?)
- Implement Kubernetes Dashboard

### Scalability

- cluster-autoscaler implementation
- Implement metrics on filewcount workload
- Implement prometheus adapter to support custom metrics
- Update HorizontalPodAutoscaler to use custom metrics
