# Argo Workflows Helm Subchart

> A **comprehensive Helm subchart** for deploying Argo Workflows with MinIO integration and CWL workflow execution capabilities as part of the ZOO-Project ecosystem.

[Argo Workflows Official Documentation](https://argoproj.github.io/argo-workflows/)

Trademarks: This software listing is packaged by the ZOO-Project developer team. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

## Introduction

This subchart bootstraps an [Argo Workflows](https://argoproj.github.io/argo-workflows/) deployment on a Kubernetes cluster using the [Helm](https://helm.sh/) package manager as part of the ZOO-Project DRU ecosystem. 

**ZOO-Project-DRU** (Deploy, Replace, Undeploy) implements the **OGC API - Processes - Part 2: Deploy, Replace, Undeploy** standard, providing dynamic deployment capabilities for geospatial processing workflows. It supports the **Common Workflow Language (CWL)** for defining and executing complex geospatial processing chains.

This subchart provides the workflow orchestration backend, including MinIO for artifact storage, Argo Events for event-driven workflows, and specialized templates for CWL workflow execution within the OGC API - Processes framework.

## Prerequisites

* Kubernetes 1.19+
* Helm 3.2.0+
* PV provisioner support in the underlying infrastructure

## Installing the Chart

## Installing the Chart

### As Part of ZOO-Project-DRU

This subchart is typically deployed as part of the main ZOO-Project DRU chart, which implements the **OGC API - Processes - Part 2: Deploy, Replace, Undeploy** standard:

```bash
# Add the ZOO-Project Helm repository
helm repo add zoo-project https://zoo-project.github.io/charts/

# Update repository information
helm repo update

# Install the complete ZOO-Project DRU stack (includes Argo Workflows)
helm install my-zoo-dru zoo-project/zoo-project-dru --version 0.5.0
```

### Standalone Installation

For development or testing purposes, this subchart can be installed independently:

```bash
# Clone the ZOO-Project charts repository
git clone https://github.com/ZOO-Project/charts.git
cd charts/zoo-project-dru/charts/argo-workflows

# Install the subchart directly
helm install my-argo-workflows . --create-namespace --namespace argo-workflows

# Or install with custom values
helm install my-argo-workflows . -f my-values.yaml --create-namespace --namespace argo-workflows
```

### Customizing Within ZOO-Project DRU

To customize the Argo Workflows subchart when deploying the full ZOO-Project DRU stack (OGC API - Processes - Part 2 implementation):

```yaml
# values.yaml for zoo-project-dru
argo-workflows:
  minio:
    external:
      enabled: true
      serviceName: "external-minio"
      port: 9000
  
  argo:
    workflows:
      controller:
        resources:
          requests:
            memory: 512Mi
            cpu: 200m
```

## Parameters

### Global Parameters

| Name | Description | Value |
|:-----|:------------|:------|
| `global.namespace` | Namespace where Argo Workflows will be deployed | `argo-workflows` |

### Controller Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `controller.instanceID` | Instance ID for the controller | `argo` |

### Argo Workflows Configuration

#### Server Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `argo.workflows.enabled` | Enable Argo Workflows deployment | `true` |
| `argo.workflows.version` | Version of Argo Workflows to deploy | `3.5.5` |
| `argo.workflows.crds.install` | Enable CRD installation | `true` |
| `argo.workflows.server.secure` | Enable HTTPS for server | `false` |
| `argo.workflows.server.authMode` | Authentication mode (server, client, sso) | `server` |
| `argo.workflows.server.namespaced` | Enable namespaced mode | `true` |
| `argo.workflows.server.env.FIRST_TIME_USER_MODAL` | Disable first time user modal | `false` |
| `argo.workflows.server.env.FEEDBACK_MODAL` | Disable feedback modal | `false` |
| `argo.workflows.server.env.NEW_VERSION_MODAL` | Disable new version modal | `false` |
| `argo.workflows.server.service.type` | Service type for Argo server | `ClusterIP` |
| `argo.workflows.server.service.port` | Service port for Argo server | `2746` |
| `argo.workflows.server.resources.limits.cpu` | CPU limit for server | `500m` |
| `argo.workflows.server.resources.limits.memory` | Memory limit for server | `512Mi` |
| `argo.workflows.server.resources.requests.cpu` | CPU request for server | `100m` |
| `argo.workflows.server.resources.requests.memory` | Memory request for server | `128Mi` |

#### Controller Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `argo.workflows.controller.namespaced` | Enable namespaced mode for controller | `true` |
| `argo.workflows.controller.instanceID` | Instance ID for controller (defaults to release name) | `""` |
| `argo.workflows.controller.resources.limits.cpu` | CPU limit for controller | `500m` |
| `argo.workflows.controller.resources.limits.memory` | Memory limit for controller | `512Mi` |
| `argo.workflows.controller.resources.requests.cpu` | CPU request for controller | `100m` |
| `argo.workflows.controller.resources.requests.memory` | Memory request for controller | `128Mi` |
| `argo.workflows.controller.parallelism` | Parallelism limits for workflows | `10` |
| `argo.workflows.controller.executor.name` | Container runtime executor (docker, pns, k8sapi, kubelet, emissary) | `docker` |
| `argo.workflows.controller.retentionPolicy.completed` | Retention for completed workflows (seconds) | `259200` |
| `argo.workflows.controller.retentionPolicy.failed` | Retention for failed workflows (seconds) | `259200` |
| `argo.workflows.controller.retentionPolicy.errored` | Retention for errored workflows (seconds) | `259200` |

### Argo Events Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `argo.events.version` | Version of Argo Events to deploy | `1.9.1` |
| `argo.events.enabled` | Enable Argo Events | `true` |
| `argo.events.imagePullPolicy` | Image pull policy for Argo Events | `Always` |
| `argo.events.replicas` | Number of controller replicas | `1` |
| `argo.events.resources.limits.cpu` | CPU limit for events controller | `500m` |
| `argo.events.resources.limits.memory` | Memory limit for events controller | `512Mi` |
| `argo.events.resources.requests.cpu` | CPU request for events controller | `100m` |
| `argo.events.resources.requests.memory` | Memory request for events controller | `128Mi` |
| `argo.events.eventBus.enabled` | Enable event bus deployment | `true` |
| `argo.events.eventBus.name` | Event bus name | `default` |
| `argo.events.eventBus.type` | Event bus type (jetstream or nats) | `jetstream` |
| `argo.events.eventBus.jetstream.version` | JetStream version | `latest` |
| `argo.events.eventBus.jetstream.replicas` | Number of JetStream replicas | `1` |
| `argo.events.eventBus.jetstream.settings` | JetStream settings configuration | `max_memory_store: -1\nmax_file_store: 1TB` |
| `argo.events.eventBus.jetstream.streamConfig` | Stream configuration | `maxMsgs: 50000\nmaxAge: 168h\nmaxBytes: -1\nreplicas: 1\nduplicates: 300s` |
| `argo.events.eventBus.nats.replicas` | Number of NATS replicas | `1` |
| `argo.events.eventBus.nats.auth` | NATS authentication type | `token` |

### Ingress Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `ingress.enabled` | Enable ingress for Argo Workflows | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts[0].host` | Hostname for ingress | `argo-workflows.local` |
| `ingress.hosts[0].paths[0].path` | Path for ingress | `/` |
| `ingress.hosts[0].paths[0].pathType` | Path type for ingress | `Prefix` |
### MinIO Configuration

#### Internal MinIO

| Name | Description | Value |
|:-----|:------------|:------|
| `minio.enabled` | Enable embedded MinIO | `true` |
| `minio.replicas` | Number of MinIO replicas | `1` |
| `minio.mode` | MinIO mode (standalone or distributed) | `standalone` |
| `minio.distributedMode.enabled` | Enable distributed mode | `false` |
| `minio.standalone.enabled` | Enable standalone mode | `true` |
| `minio.persistence.enabled` | Enable persistent storage for MinIO | `true` |
| `minio.persistence.size` | Size of MinIO persistent volume | `10Gi` |
| `minio.resources.requests.memory` | Memory request for MinIO | `256Mi` |
| `minio.resources.requests.cpu` | CPU request for MinIO | `100m` |
| `minio.resources.limits.memory` | Memory limit for MinIO | `512Mi` |
| `minio.resources.limits.cpu` | CPU limit for MinIO | `250m` |
| `minio.defaultBuckets` | Default bucket name | `argo-artifacts` |
| `minio.auth.rootUser` | MinIO root username | `minio-admin` |
| `minio.auth.rootPassword` | MinIO root password | `minio-admin` |
| `minio.buckets[0].name` | First bucket name | `argo-artifacts` |
| `minio.buckets[0].policy` | First bucket policy | `none` |
| `minio.buckets[0].purge` | Purge bucket on deletion | `false` |
| `minio.buckets[1].name` | Second bucket name | `results` |
| `minio.buckets[1].policy` | Second bucket policy | `none` |
| `minio.buckets[1].purge` | Purge bucket on deletion | `false` |
| `minio.service.type` | MinIO service type | `ClusterIP` |
| `minio.service.ports.api` | MinIO API port | `9000` |
| `minio.service.ports.console` | MinIO console port | `9001` |
| `minio.extraEnvVars[0].name` | Environment variable name | `MINIO_DISTRIBUTED_MODE_ENABLED` |
| `minio.extraEnvVars[0].value` | Environment variable value | `no` |

#### External MinIO

| Name | Description | Value |
|:-----|:------------|:------|
| `minio.external.enabled` | Use external MinIO instead of embedded one | `false` |
| `minio.external.endpoint` | Complete endpoint URL (takes precedence over serviceName) | `""` |
| `minio.external.serviceName` | Service name for constructing URL | `s3-service` |
| `minio.external.port` | Service port for constructing URL | `9000` |
| `minio.external.secure` | Use HTTPS for connection | `false` |
| `minio.external.accessKeySecret.name` | Secret name containing access key | `s3-service` |
| `minio.external.accessKeySecret.key` | Key in secret containing access key | `root-user` |
| `minio.external.secretKeySecret.name` | Secret name containing secret key | `s3-service` |
| `minio.external.secretKeySecret.key` | Key in secret containing secret key | `root-password` |

### RBAC Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `rbac.create` | Create RBAC resources | `true` |

### Service Account Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |

### Security Context

| Name | Description | Value |
|:-----|:------------|:------|
| `podSecurityContext` | Pod security context | `{}` |
| `securityContext.capabilities.drop` | Capabilities to drop | `["ALL"]` |
| `securityContext.readOnlyRootFilesystem` | Enable read-only root filesystem | `false` |
| `securityContext.runAsNonRoot` | Run as non-root user | `true` |
| `securityContext.runAsUser` | User ID to run as | `1000` |

### Node Scheduling

| Name | Description | Value |
|:-----|:------------|:------|
| `nodeSelector` | Node selector for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity for pod assignment | `{}` |

### Persistence Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `persistence.enabled` | Enable persistent storage for workflow data | `true` |
| `persistence.storageClass` | Storage class for persistent volume | `""` |
| `persistence.accessMode` | Access mode for persistent volume | `ReadWriteMany` |
| `persistence.size` | Size of persistent volume | `5Gi` |

### CWL Runner Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `cwlRunner.enabled` | Enable CWL runner workflow templates | `true` |
| `cwlRunner.image.repository` | CWL runner image repository | `terradue/calrissian` |
| `cwlRunner.image.tag` | CWL runner image tag | `0.99` |
| `cwlRunner.image.pullPolicy` | CWL runner image pull policy | `IfNotPresent` |
| `cwlRunner.defaultResources.maxRam` | Default max RAM for CWL jobs | `4G` |
| `cwlRunner.defaultResources.maxCores` | Default max cores for CWL jobs | `4` |
| `cwlRunner.resources.requests.memory` | Memory request for CWL runner | `256Mi` |
| `cwlRunner.resources.requests.cpu` | CPU request for CWL runner | `100m` |
| `cwlRunner.resources.limits.memory` | Memory limit for CWL runner | `2Gi` |
| `cwlRunner.resources.limits.cpu` | CPU limit for CWL runner | `2` |

### Stage-in/Stage-out Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `stageInOut.enabled` | Enable stage-in/stage-out workflow template | `true` |
| `stageInOut.image` | Image for stage-in/stage-out containers | `alpine/curl` |
| `stageInOut.tag` | Tag for stage-in/stage-out image | `latest` |
| `stageInOut.resources.requests.memory` | Memory request for stage-in/out jobs | `128Mi` |
| `stageInOut.resources.requests.cpu` | CPU request for stage-in/out jobs | `50m` |
| `stageInOut.resources.limits.memory` | Memory limit for stage-in/out jobs | `512Mi` |
| `stageInOut.resources.limits.cpu` | CPU limit for stage-in/out jobs | `500m` |
| `stageInOut.semaphore.workflow` | Semaphore limit for workflow throttling | `3` |
| `stageInOut.userSettings` | User settings for S3 access (templated if empty) | `""` |

### CWL Wrapper Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `wrapper.rules` | Rules configuration (templated if empty) | `""` |
| `wrapper.main` | Main CWL configuration (templated if empty) | `""` |
| `wrapper.stageIn` | Stage-in CWL configuration (templated if empty) | `""` |
| `wrapper.stageOut` | Stage-out CWL configuration (templated if empty) | `""` |

### Additional Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `featureCollectionScript` | Feature collection script (templated if empty) | `""` |
| `cwlwrapperImage` | CWL wrapper image with specific SHA | `eoepca/cwl-wrapper@sha256:02f4a84d7cfdb7035cd6d58c1d9fca3f9c5e24bf2a1ea577312297f2c42574bd` |
| `stageOutImage` | Stage-out image | `ghcr.io/eoap/mastering-app-package/stage:1.1.0` |

### Synchronization Configuration

| Name | Description | Value |
|:-----|:------------|:------|
| `synchronization.enabled` | Enable synchronization | `true` |
| `synchronization.semaphoreName` | Semaphore name for synchronization | `semaphore-argo-cwl-runner` |

### Monitoring Configuration

#### General Monitoring

| Name | Description | Value |
|:-----|:------------|:------|
| `monitoring.enabled` | Enable monitoring components | `true` |

#### Prometheus Integration

| Name | Description | Value |
|:-----|:------------|:------|
| `monitoring.prometheus.enabled` | Enable Prometheus ServiceMonitor | `true` |
| `monitoring.prometheus.serviceMonitor.enabled` | Enable ServiceMonitor creation | `true` |
| `monitoring.prometheus.serviceMonitor.interval` | Scraping interval | `30s` |
| `monitoring.prometheus.serviceMonitor.path` | Scraping path | `/metrics` |
| `monitoring.prometheus.serviceMonitor.additionalLabels` | Additional labels for ServiceMonitor | `{}` |
| `monitoring.prometheus.serviceMonitor.namespaceSelector` | Namespace selector | `{}` |
| `monitoring.prometheus.prometheusRule.enabled` | Enable PrometheusRule creation | `true` |
| `monitoring.prometheus.prometheusRule.additionalLabels` | Additional labels for PrometheusRule | `{}` |

#### Grafana Integration

| Name | Description | Value |
|:-----|:------------|:------|
| `monitoring.grafana.enabled` | Enable Grafana dashboard creation | `true` |
| `monitoring.grafana.dashboard.additionalLabels.grafana_dashboard` | Label for dashboard discovery | `1` |
| `monitoring.grafana.dashboard.folder` | Grafana folder for dashboard | `Argo Workflows` |

## Installation

### Prerequisites

- Kubernetes 1.18+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)

### Installing the Subchart

**Note**: This is typically deployed as part of the ZOO-Project DRU chart. For standalone installation:

```bash
helm install my-argo-workflows ./charts/argo-workflows
```

The command deploys Argo Workflows on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

### Custom Configuration

For standalone installation with custom values:

```bash
helm install my-argo-workflows ./charts/argo-workflows -f my-values.yaml
```

For configuration within the ZOO-Project DRU chart, prefix all values with `argo-workflows:`:

```yaml
# values.yaml for zoo-project-dru
argo-workflows:
  # Use external MinIO
  minio:
    external:
      enabled: true
      serviceName: "external-minio"
      port: 9000
      secure: false

  # Enable ingress with TLS
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: argo-workflows.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: argo-workflows-tls
        hosts:
          - argo-workflows.example.com

  # Increase resources for high workload
  argo:
    workflows:
      controller:
        resources:
          requests:
            memory: 512Mi
            cpu: 200m
          limits:
            memory: 1Gi
            cpu: 500m
```

### Configuration Examples

#### Internal MinIO Setup

For standalone installation:
```yaml
minio:
  enabled: true
  persistence:
    enabled: true
    size: 20Gi
  auth:
    rootUser: "my-admin"
    rootPassword: "my-secret-password"
```

For ZOO-Project DRU integration:
```yaml
argo-workflows:
  minio:
    enabled: true
    persistence:
      enabled: true
      size: 20Gi
    auth:
      rootUser: "my-admin"
      rootPassword: "my-secret-password"
```

#### External MinIO Setup

For standalone installation:
```yaml
minio:
  external:
    enabled: true
    endpoint: "https://external-minio.example.com"
    accessKeySecret:
      name: "minio-credentials"
      key: "access-key"
    secretKeySecret:
      name: "minio-credentials"
      key: "secret-key"
```

For ZOO-Project DRU integration:
```yaml
argo-workflows:
  minio:
    external:
      enabled: true
      endpoint: "https://external-minio.example.com"
      accessKeySecret:
        name: "minio-credentials"
        key: "access-key"
      secretKeySecret:
        name: "minio-credentials"
        key: "secret-key"
```

#### CWL Runner Configuration

For standalone installation:
```yaml
cwlRunner:
  enabled: true
  defaultResources:
    maxRam: "8G"
    maxCores: 8
  resources:
    limits:
      memory: "4Gi"
      cpu: 4
```

For ZOO-Project DRU integration:
```yaml
argo-workflows:
  cwlRunner:
    enabled: true
    defaultResources:
      maxRam: "8G"
      maxCores: 8
    resources:
      limits:
        memory: "4Gi"
        cpu: 4
```

### Upgrading the Subchart

When using as part of ZOO-Project DRU:

```bash
helm upgrade my-zoo-dru zoo-project/zoo-project-dru
```

For standalone deployment:

```bash
helm upgrade my-argo-workflows ./charts/argo-workflows
```

### Uninstalling the Subchart

When using as part of ZOO-Project DRU, uninstall the complete stack:

```bash
helm uninstall my-zoo-dru
```

For standalone deployment:

```bash
helm uninstall my-argo-workflows
```

The command removes all the Kubernetes components associated with the subchart and deletes the release.

## Usage

### Accessing Argo Workflows UI

After installation, access the Argo Workflows UI through:

1. **Port forwarding** (for development):
   ```bash
   kubectl port-forward svc/my-argo-workflows-argo-server 2746:2746
   ```
   Then open `http://localhost:2746` in your browser.

2. **Ingress** (for production):
   Configure the ingress section in values and access via the configured hostname.

### Submitting Workflows

Use the Argo CLI or UI to submit workflows:

```bash
# Install Argo CLI
curl -sLO https://github.com/argoproj/argo-workflows/releases/latest/download/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
sudo mv ./argo-linux-amd64 /usr/local/bin/argo

# Submit a workflow
argo submit --watch https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml
```

### CWL Workflow Support

This subchart includes built-in support for **Common Workflow Language (CWL)** workflows as part of the **OGC API - Processes - Part 2** implementation:

1. **CWL Runner**: Uses Calrissian for executing CWL workflows in the OGC processes context
2. **Stage-in/Stage-out**: Handles data transfer to/from S3 storage for geospatial data processing
3. **Workflow Templates**: Pre-configured templates for CWL execution within the Deploy, Replace, Undeploy framework

Example CWL workflow submission:
```bash
argo submit -p cwl-file="my-workflow.cwl" -p input-file="input.json" cwl-runner-template
```

## Troubleshooting

### Common Issues

1. **Pod stuck in Pending state**
   - Check if PV provisioner is available
   - Verify resource requests don't exceed cluster capacity

2. **S3 connection issues**
   - Verify MinIO/S3 credentials are correct
   - Check if endpoint is accessible from cluster
   - Ensure bucket exists and has proper permissions

3. **Workflow execution failures**
   - Check controller logs: `kubectl logs -l app.kubernetes.io/name=argo-workflows-controller`
   - Verify RBAC permissions are correctly configured
   - Check if required secrets exist

### Debug Commands

```bash
# Check controller status
kubectl get pods -l app.kubernetes.io/name=argo-workflows-controller

# View controller logs
kubectl logs -l app.kubernetes.io/name=argo-workflows-controller

# Check workflow status
argo list

# Get workflow details
argo get <workflow-name>

# View workflow logs
argo logs <workflow-name>
```

## Contributing

This subchart is part of the ZOO-Project charts repository. Please read the contributing guidelines in the main repository for details on our code of conduct and the process for submitting pull requests.

## License

This subchart is licensed under the Apache License 2.0. See the LICENSE file for details.
