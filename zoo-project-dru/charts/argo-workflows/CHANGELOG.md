# Changelog

All notable changes to the Argo Workflows Helm Chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2025-07-16

### Fixed
- **BREAKING FIX**: Replaced deprecated `containerRuntimeExecutor` with `executor.name` in workflow controller configuration
  - Resolves JSON unmarshaling error: `unknown field "containerRuntimeExecutor"`
  - Now compatible with Argo Workflows 3.5.5 API specification
- **CRITICAL FIX**: Resolved duplicate `executor` key in workflow controller configmap
  - Merged executor runtime configuration and resource configuration into single block
  - Fixes YAML parsing error: `key "executor" already set in map`
- **CRITICAL FIX**: Removed deprecated `namespaced` field from workflow controller configmap
  - Resolves JSON unmarshaling error: `unknown field "namespaced"`
  - Namespaced mode now properly configured via controller arguments `--namespaced` and `--managed-namespace`
  - Maintains backward compatibility with values.yaml configuration
- **CRITICAL FIX**: Fixed `retentionPolicy` values format
  - Resolves JSON unmarshaling error: `cannot unmarshal string into Go struct field RetentionPolicy.retentionPolicy.completed of type int`
  - Changed from string format (`3d`) to numeric format (seconds: `259200`)
  - Added configurable retention policy in values.yaml with optimized settings for hostpath profile
- Updated workflow controller configmap template to use proper executor configuration
- Added configurable executor support with multiple options (docker, pns, k8sapi, kubelet, emissary)

### Added
- Executor configuration in values.yaml with default set to "docker"
- Hostpath storage class support for local development environments (minikube, kind, Docker Desktop)
- Dedicated values_hostpath.yaml for hostpath-specific configurations
- Skaffold hostpath profile for simplified local deployment
- Test script (test-config.sh) to validate chart configuration
- Enhanced documentation for executor options and troubleshooting

### Configuration Changes
**Before (deprecated):**
```yaml
# In ConfigMap (no longer supported)
containerRuntimeExecutor: docker
namespaced: true
retentionPolicy:
  completed: 3d  # String format not supported
  failed: 3d
  errored: 3d

# Duplicate executor sections
executor:
  name: docker
# ... later in config ...
executor:
  resources: {...}
```

**After (current):**
```yaml
# In ConfigMap (correct format)
executor:
  name: docker
  imagePullPolicy: IfNotPresent
  resources:
    requests: {...}
    limits: {...}

retentionPolicy:
  completed: 259200  # Numeric format in seconds (3 days)
  failed: 259200
  errored: 259200

# Namespaced mode configured via deployment arguments
args:
  - --namespaced=true
  - --managed-namespace=argo-workflows
```

### Migration Notes
- No manual migration required - the chart automatically uses the new configuration format
- Existing deployments will automatically pick up the new configuration on next deployment
- All executor types (docker, pns, k8sapi, kubelet, emissary) are now supported and configurable

### Supported Executors
- **docker**: Uses Docker daemon (requires Docker socket access)
- **pns**: Process Namespace Sharing (recommended for security)
- **k8sapi**: Uses Kubernetes API (most compatible, slower)
- **kubelet**: Direct kubelet access (requires kubelet permissions)
- **emissary**: HTTP-based executor (recommended for newer clusters)

## [0.2.0] - 2025-07-16

### Added
- Complete CWL (Common Workflow Language) support with Calrissian runner
- MinIO S3-compatible storage for workflow artifacts
- Example WorkflowTemplates including water bodies detection
- Post-deployment hooks for template stability
- Stage-out functionality for STAC catalog publishing
- Validation schemas for workflow inputs
- Comprehensive documentation and API usage guide

### Features
- Argo Workflows 3.5.5 with namespaced deployment
- Argo Events 1.9.1 for event-driven workflows
- Integrated MinIO for artifact storage
- CWL workflow execution with Calrissian
- Example templates for common geospatial workflows
- Helm hooks for proper deployment sequencing

### Configuration
- Configurable resource limits and requests
- Flexible storage configurations
- RBAC and security context settings
- Ingress support for external access
- Customizable MinIO credentials and buckets

## [0.1.0] - 2025-07-16

### Added
- Initial release of Argo Workflows Helm chart
- Basic Argo Workflows deployment
- MinIO integration for artifacts
- Essential RBAC configurations
