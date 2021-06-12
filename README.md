# filewcount in Kubernetes with GitOps

This repo is an implementation of the [filewcount](https://hub.docker.com/r/bldrtech/filewcount) Docker container in a Kubernetes cluster with deployment via [GitOps](https://www.weave.works/technologies/gitops/) using [Flux V2](https://fluxcd.io/docs/).  This showcases the orchestration of the filewcount workload, monitoring, and management in a Kubernetes cluster provided by Kind (Kubernetes in Docker).  The GitOps deployment architecture was chosen for its declarative nature and relative lack of local dependencies.  To see how this implementation could be improved and expanded upon, please see the *Work Remaining* section below.

## Workload architecture

The filewcount workload runs in a Kind Kubernetes cluster as a Deployment.  This Deployment has multiple replica Pods to enable rolling upgrades with zero downtime.  In addition, the Deployment is paired with a HorizontalPodAutoscaler which can automatically scale the number of Pods according to the load on the existing Pods.  A Service aggregates access to all of the Pods behind a single endpoint.  This Service is best accessed (at this time) by port forwarding the Service to the host machine using the `./forward-filewcount` script.  Users may then access the filewcount application at [http://localhost:8080](http://localhost:8080)

## Environment

- `GITHUB_TOKEN` is a GitHub Access Token with git repo read/write permissions to the homework repo.  This is used to create the GitOps sync between the Kubernetes cluster and the repo.

## Setting Up

Bootstrapping of the environment and deployment of the filewcount workload are accomplished by running the scripts provided in the root directory of the repo.  The bootstrap script creates the Kind Kubernetes cluster and starts the GitOps process by installing and configuring Flux on the cluster.  Flux will then sync the Kubernetes manifests in the git repo to the cluster, and the filewcount workload and associated management tools and infrastructure will be installed and configured.

**Note**: all scripts are intended to run on macOS and Linux

```bash
GITHUB_TOKEN={YOUR_TOKEN_HERE} ./bootstrap-kind
```

## Tearing Down

Tearing down the environment simply deletes the Kind Kubernetes cluster.

```bash
./teardown-kind
```

## Accessing filewcount

As ingress has not been provided in this implementation, the port that the filewcount Service listens on must be forwarded to the host machine, then the filewcount application may be accessed at [http://localhost:8080](http://localhost:8080)

```bash
./forward-filewcount &
sleep 3 && \
open http://localhost:8080
```

## Upgrades and Management

This system uses GitOps for deployment of manifests to Kubernetes via a synchronization provided by Flux.  All manifests that the system relies on are continuously synced with the cluster according to their respective schedules. This synchronization means that all creation, deletion, and updates of resources in Kubernetes are controlled by the contents of this git repo.  By performing the desired changes locally, and then either pushing (if using trunk-based development) or creating and merging a pull request (if using github flow or similar), the flux operators in the cluster will automatically update the contents of the cluster after the git branch has been updated.

### Examples

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
kubectl get namespaces --watch
```

#### Resource Deletion

Kubernetes resources may be deleted by committing the deletion of the appropriate Kubernetes manifest to the repo and allowing the sync process to complete.

```bash
rm ./kube/kustomize/sync-example.yaml && \
git add ./kube/kustomize/sync-example.yaml && \
git commit -m 'delete example namespace' && \
git push -u origin HEAD && \
echo "You should see the 'sync-example' namespace deleted when reconciliation is complete"
kubectl get namespaces --watch
```

#### Workload Rolling Upgrade

Kubernetes resources may be updated by committing a change of the appropriate Kubernetes manifest to the repo and allowing the sync process to complete.

##### Upgrade

```bash
cat ./kube/kustomize/filewcount.yaml | \
sed -e 's/filewcount:.*/filewcount:2.0/' > \
./kube/kustomize/filewcount-new.yaml && \
mv ./kube/kustomize/filewcount-new.yaml ./kube/kustomize/filewcount.yaml
git add ./kube/kustomize/filewcount.yaml && \
git commit -m 'upgrade filewcount to 2.0' && \
git push -u origin HEAD && \
echo "You should see the a rolling update of the filewcount pods"
kubectl get pods --namespace filewcount --watch
```

##### Downgrade

```bash
cat ./kube/kustomize/filewcount.yaml | \
sed -e 's/filewcount:.*/filewcount:1.0/' > \
./kube/kustomize/filewcount-new.yaml && \
mv ./kube/kustomize/filewcount-new.yaml ./kube/kustomize/filewcount.yaml
git add ./kube/kustomize/filewcount.yaml && \
git commit -m 'downgrade filewcount to 1.0' && \
git push -u origin HEAD && \
echo "You should see the a rolling update of the filewcount pods"
kubectl get pods --namespace filewcount --watch
```

## Observability

There are multiple mechanisms for observability that have been provided in this implementation.  They are detailed below.

### Metrics

Performance metrics (cpu and memory usage) for the Pods and Nodes in the cluster are collected by `metrics-server` and are consumed by HorizontalPodAutoscalers for scaling workloads as well as made available via the Kubernetes cli:

```bash
kubectl top nodes
kubectl top pods -A
```

Metrics in the system are scraped from Nodes, Pods, Services, and `metrics-server` by prometheus and made available for consumption by Grafana

```bash
./forward-grafana &
echo 'username: admin' && \
echo 'password: prom-operator' && \
sleep 3 && \
open http://localhost:8081/d/flux-cluster/flux-cluster-stats?orgId=1&refresh=10s
```

### Application Logs

Application logs for currently running Pods are available from the Kubernetes API

```bash
# Logs for filewcount Pods
kubectl logs --namespace filewcount --selector app=filewcount
```

### Events

System Events are available from the Kubernetes API. These include events created by workloads running in Kubernetes.

```bash
kubectl get events --all-namespaces
```

## Testing

Load testing was conducted using the `ab` utility to perform a large volume of concurrent requests against the filewcount application.  The particular test profile used can be executed with the `load-test` script.  During the execution of this script, the correct operation of the HorizontalPodAutoscaler was observed, automatically scaling the number of filewcount Pods according to the defined parameters.  The results of the load test were used to tune the Pod resource requests (which are used by Kubernetes for scheduling Pods to Nodes) and resource limits (which are used by Kubernetes to protect access to resources by other Pods).

## Work Remaining

It is acknowledged that this implementation is not completely representative of a production capable system in the following ways:

1. Kind is a Kubernetes distribution that is best used for rapid development of Kubernetes workloads and is not production-ready. Given additional time, the Kind cluster could be replaced with an AWS EKS cluster.
2. Kind, in its use as a local development cluster is not suited to setup of ingress on a domain and generation and installation of a TLS certificate for this ingress.  Once transitioned to AWS EKS, implementation of ingress using an AWS ELB and automatic provisioning of a TLS certificate via cert-manager would be straightforward.
3. The stateful portions of the implementation, chiefly the volumes backing the prometheus instance in the monitoring namespace, have no persistence or backup mechanism to ensure that data is not lost when the cluster is recreated or if errors occur.

A rough to-do list follows:

### Security

- Implement linting and resource scanning of K8s manifests in CI pipeline
- Update credentials for Grafana to use non-default
- Implement TLS ingress and cert-manager for auto-provisioning of certificates
- Implement in-cluster policy framework like open-policy-agent or kyverno to ensure operational security and correctness of cluster and workload

### Infrastructure

- Demonstrate bootstrapping to AWS EKS cluster instead of Kind
- Demonstrate ingress controller binding to AWS ELB

### Monitoring

- Implement readiness and liveness probes for filewcount Pods
- Implement log scraping and analysis (elastic stack?)
- Implement alerting from any/all sources (metrics, logs, events)
- Implement Kubernetes Dashboard

### Scalability

- Implement cluster-autoscaler to automatically increase number of nodes in the cluster according to Kubernetes scheduling needs
- Implement metrics on filewcount workload, to get detailed insight into application performance
- Implement prometheus adapter to support custom metrics of workload (instead of cpu and memory metrics which are available for all pods)
- Update HorizontalPodAutoscaler to use the workload's custom metrics for more accurate and efficient scaling
