# filewcount in Kubernetes with GitOps

An implementation of the [filewcount](https://hub.docker.com/r/bldrtech/filewcount) Docker container in a Kubernetes cluster with deployment via [GitOps](https://www.weave.works/technologies/gitops/) via [Flux V2](https://fluxcd.io/docs/).  This repo showcases the orchestration of the filewcount workload, monitoring, and management in a Kubernetes cluster provides by Kind (Kubernetes in Docker).

## Environment

- `GITHUB_TOKEN` is a GitHub Access Token with git repo read/write permissions to the homework repo.


- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Setting Up

Bootstrapping of the environment and deployment of the filewcount workload are accomplished by running the

Note: this script is intended to run on macOS and Linux machines

```bash
GITHUB_TOKEN={YOUR_TOKEN_HERE} ./bootstrap-kind
```

## Tearing Down

```bash
./teardown-kind
```


## Upgrades and Management

This system uses GitOps for deployment of manifests to Kubernetes via a synchronization provided by Flux.  All manifests that the system relies on are continuously synced with the cluster according to their respective schedules. This synchronization means that all creation, deletion, and updates of resources in Kubernetes are controlled by the contents of this git repo.  By perfoming the desired changes locally, and then either pushing (if using trunk-based development) or creating and merging a pull request (if using github flow or similar), the flux operators in the cluster will automatically update the contents of the cluster after the git branch has been updated.

### Example

#### Resource Creation

```bash
echo <<<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: sync-example
EOF > ./kube/kustomize/sync-example.yaml
git add ./kube/kustomize/sync-example.yaml
git commit -m 'create example namespace'
git push -u origin HEAD
kubectl get namespaces --watch
# You should see the 'sync-example' namespace created when reconciliation is complete
```

#### Resource Deletion

```bash
rm ./kube/kustomize/sync-example.yaml
git add ./kube/kustomize/sync-example.yaml
git commit -m 'delete example namespace'
git push -u origin HEAD
kubectl get namespaces --watch
# You should see the 'sync-example' namespace deleted when reconciliation is complete
```

## Monitoring

- metrics
- logs
- events

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
