# filewcount in Kubernetes with GitOps

An implementation of the [filewcount](https://hub.docker.com/r/bldrtech/filewcount) Docker container in a Kubernetes cluster with deployment via [GitOps](https://www.weave.works/technologies/gitops/) via [Flux V2](https://fluxcd.io/docs/).  This repo showcases the orchestration of the filewcount workload, monitoring, and management in a Kubernetes cluster provides by Kind (Kubernetes in Docker).  To see how this implementation could be improved and expanded upon, please see the *Work Remaining* section below.

## Environment

- `GITHUB_TOKEN` is a GitHub Access Token with git repo read/write permissions to the homework repo.  This is used to create the GitOps sync between the Kubernetes cluster and the repo.

## Setting Up

Bootstrapping of the environment and deployment of the filewcount workload are accomplished by running the scripts provided in the root directory of the repo.  The bootstrap script creates the Kind Kubernetes cluster and starts the GitOps process by installing and configuring Flux on the cluster.  Flux will then sync the Kubernetes manifests in the git repo to the cluster, and the filewcount workload and associated management tools and infrastructure will be installed and configured.

**Note**: this script is intended to run on macOS and Linux machines

```bash
GITHUB_TOKEN={YOUR_TOKEN_HERE} ./bootstrap-kind
```

## Tearing Down

Tearing down the environment simply deletes the Kind Kubernetes cluster.

```bash
./teardown-kind
```

## Upgrades and Management

This system uses GitOps for deployment of manifests to Kubernetes via a synchronization provided by Flux.  All manifests that the system relies on are continuously synced with the cluster according to their respective schedules. This synchronization means that all creation, deletion, and updates of resources in Kubernetes are controlled by the contents of this git repo.  By perfoming the desired changes locally, and then either pushing (if using trunk-based development) or creating and merging a pull request (if using github flow or similar), the flux operators in the cluster will automatically update the contents of the cluster after the git branch has been updated.

### Example

#### Resource Creation

Kubernetes resources may be created by committing the appropriate Kubernetes manifest to the repo and allowing the sync process to complete.

```bash
cat << EOF > ./kube/kustomize/sync-example.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: sync-example
EOF
git add ./kube/kustomize/sync-example.yaml && \
git commit -m 'create example namespace' && \
git push -u origin HEAD && \
echo "You should see the 'sync-example' namespace created when reconciliation is complete"
watch -n 1 'kubectl get namespaces'
```

#### Resource Deletion

Kubernetes resources may be deleted by committing the deletion of the appropriate Kubernetes manifest to the repo and allowing the sync process to complete.

```bash
rm ./kube/kustomize/sync-example.yaml && \
git add ./kube/kustomize/sync-example.yaml && \
git commit -m 'delete example namespace' && \
git push -u origin HEAD && \
echo "You should see the 'sync-example' namespace deleted when reconciliation is complete"
watch -n 1 'kubectl get namespaces'
```

#### Workload Rolling Upgrade

Kubernetes resources may be updated by committing a change of the appropriate Kubernetes manifest to the repo and allowing the sync process to complete.

```bash
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
