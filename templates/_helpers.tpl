{{/*
=============================================================================
NAMING
=============================================================================
*/}}
{{/*
Expand the name of the chart.
*/}}
{{- define "universal-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "universal-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "universal-chart.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "universal-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "universal-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "universal-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "universal-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "universal-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image string helper
*/}}
{{- define "universal-chart.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
=============================================================================
CHECKSUM — auto-restart pods when ConfigMaps or Secrets change
=============================================================================
Usage: add to pod annotations:
  annotations:
    {{- include "universal-chart.checksumAnnotations" . | nindent 8 }}
*/}}
{{- define "universal-chart.checksumAnnotations" -}}
{{- if .Values.checksums.enabled }}
{{- if .Values.configMaps }}
checksum/configmaps: {{ .Values.configMaps | toYaml | sha256sum }}
{{- end }}
{{- if .Values.secrets }}
checksum/secrets: {{ .Values.secrets | toYaml | sha256sum }}
{{- end }}
{{- end }}
{{- end }}

{{/*
=============================================================================
VALIDATION — fail fast on bad config
=============================================================================
*/}}
{{- define "universal-chart.validate" -}}
{{- $validTypes := list "deployment" "statefulset" "daemonset" }}
{{- if not (has .Values.workload.type $validTypes) }}
{{- fail (printf "workload.type must be one of %v, got: %s" $validTypes .Values.workload.type) }}
{{- end }}
{{- if and .Values.ingress.enabled .Values.route.enabled }}
{{- fail "ingress.enabled and route.enabled cannot both be true — pick one" }}
{{- end }}
{{- if and (eq .Values.workload.type "daemonset") .Values.hpa.enabled }}
{{- fail "hpa is not supported for daemonset workloads" }}
{{- end }}
{{- end }}
