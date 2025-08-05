{{/*
Expand the name of the chart.
*/}}
{{- define "argo-workflows.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-workflows.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argo-workflows.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "argo-workflows.labels" -}}
helm.sh/chart: {{ include "argo-workflows.chart" . }}
{{ include "argo-workflows.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argo-workflows.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argo-workflows.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "argo-workflows.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argo-workflows.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Argo Workflows Server labels
*/}}
{{- define "argo-workflows.server.labels" -}}
{{ include "argo-workflows.labels" . }}
app.kubernetes.io/component: server
{{- end }}

{{/*
Argo Workflows Controller labels
*/}}
{{- define "argo-workflows.controller.labels" -}}
{{ include "argo-workflows.labels" . }}
app.kubernetes.io/component: workflow-controller
{{- end }}

{{/*
Argo Events Controller labels
*/}}
{{- define "argo-workflows.events.labels" -}}
{{ include "argo-workflows.labels" . }}
app.kubernetes.io/component: argo-events
{{- end }}

{{/*
MinIO labels
*/}}
{{- define "argo-workflows.minio.labels" -}}
{{ include "argo-workflows.labels" . }}
app.kubernetes.io/component: minio
{{- end }}

{{/*
Generate namespace
*/}}
{{- define "argo-workflows.namespace" -}}
{{- default .Release.Namespace .Values.global.namespace }}
{{- end }}

{{/*
MinIO endpoint URL
*/}}
{{- define "argo-workflows.minio.endpoint" -}}
{{- if .Values.minio.external.enabled -}}
{{- if and .Values.minio.external.endpoint (ne .Values.minio.external.endpoint "") -}}
{{- .Values.minio.external.endpoint -}}
{{- else -}}
{{- $protocol := "http" -}}
{{- if .Values.minio.external.secure -}}
{{- $protocol = "https" -}}
{{- end -}}
{{- printf "%s://%s.%s.svc.cluster.local:%v" $protocol .Values.minio.external.serviceName (include "argo-workflows.namespace" .) .Values.minio.external.port -}}
{{- end -}}
{{- else if .Values.minio.enabled -}}
{{- printf "http://%s-minio.%s.svc.cluster.local:%v" (include "argo-workflows.fullname" .) (include "argo-workflows.namespace" .) .Values.minio.service.ports.api -}}
{{- end -}}
{{- end }}

{{/*
MinIO endpoint hostname:port (without protocol) for Argo Workflows S3 configuration
*/}}
{{- define "argo-workflows.minio.endpointHostPort" -}}
{{- if .Values.minio.external.enabled -}}
{{- if and .Values.minio.external.endpoint (ne .Values.minio.external.endpoint "") -}}
{{- .Values.minio.external.endpoint | trimPrefix "https://" | trimPrefix "http://" -}}
{{- else -}}
{{- printf "%s.%s.svc.cluster.local:%v" .Values.minio.external.serviceName (include "argo-workflows.namespace" .) .Values.minio.external.port -}}
{{- end -}}
{{- else if .Values.minio.enabled -}}
{{- printf "%s-minio.%s.svc.cluster.local:%v" (include "argo-workflows.fullname" .) (include "argo-workflows.namespace" .) .Values.minio.service.ports.api -}}
{{- end -}}
{{- end }}

{{/*
Artifact repository configuration
*/}}
{{- define "argo-workflows.artifactRepository" -}}
{{- if or .Values.minio.enabled .Values.minio.external.enabled }}
s3:
  endpoint: {{ include "argo-workflows.minio.endpointHostPort" . }}
  bucket: {{ .Values.minio.defaultBuckets }}
  {{- if .Values.minio.external.enabled }}
  insecure: {{ not .Values.minio.external.secure }}
  accessKeySecret:
    name: {{ .Values.minio.external.accessKeySecret.name }}
    key: {{ .Values.minio.external.accessKeySecret.key }}
  secretKeySecret:
    name: {{ .Values.minio.external.secretKeySecret.name }}
    key: {{ .Values.minio.external.secretKeySecret.key }}
  {{- else }}
  insecure: true
  accessKeySecret:
    name: {{ include "argo-workflows.fullname" . }}-minio-secret
    key: accesskey
  secretKeySecret:
    name: {{ include "argo-workflows.fullname" . }}-minio-secret
    key: secretkey
  {{- end }}
{{- end }}
{{- end }}

{{/*
Bearer token instructions for API access
*/}}
{{- define "argo-workflows.bearerToken" -}}
# Get the Bearer token for API access:
export ARGO_TOKEN="Bearer $(kubectl get -n {{ include "argo-workflows.namespace" . }} secret {{ include "argo-workflows.serviceAccountName" . }}.service-account-token -o=jsonpath='{.data.token}' | base64 --decode)"

# Test API access:
curl -H "Authorization: $ARGO_TOKEN" http://localhost:2746/api/v1/workflows/{{ include "argo-workflows.namespace" . }}

# List WorkflowTemplates:
curl -H "Authorization: $ARGO_TOKEN" http://localhost:2746/api/v1/workflow-templates/{{ include "argo-workflows.namespace" . }}
{{- end }}

{{/*
API access instructions
*/}}
{{- define "argo-workflows.apiInstructions" -}}
🔑 API Access Instructions:
============================

1. Get the Bearer token:
   export ARGO_TOKEN="Bearer $(kubectl get -n {{ include "argo-workflows.namespace" . }} secret {{ include "argo-workflows.serviceAccountName" . }}.service-account-token -o=jsonpath='{.data.token}' | base64 --decode)"

2. Test API access:
   curl -H "Authorization: $ARGO_TOKEN" http://localhost:2746/api/v1/workflows/{{ include "argo-workflows.namespace" . }}

3. List WorkflowTemplates:
   curl -H "Authorization: $ARGO_TOKEN" http://localhost:2746/api/v1/workflow-templates/{{ include "argo-workflows.namespace" . }}

4. Access Argo UI:
   kubectl port-forward -n {{ include "argo-workflows.namespace" . }} svc/argo-server 2746:2746
   Open: http://localhost:2746

5. Access MinIO Console:
   kubectl port-forward -n {{ include "argo-workflows.namespace" . }} svc/minio 9001:9001
   Open: http://localhost:9001 (minio-admin/minio-admin)
{{- end }}

{{/*
Controller Instance ID for Argo Workflows
*/}}
{{- define "argo-workflows.controller.instanceID" -}}
{{- if .Values.argo.workflows.controller.instanceID }}
{{- .Values.argo.workflows.controller.instanceID }}
{{- else }}
{{- .Release.Name }}
{{- end }}
{{- end }}
