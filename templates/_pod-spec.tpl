{{/*
=============================================================================
SHARED POD SPEC — used by Deployment, StatefulSet, DaemonSet
=============================================================================
Call: {{- include "universal-chart.podSpec" . | nindent 6 }}
*/}}
{{- define "universal-chart.podSpec" -}}
serviceAccountName: {{ include "universal-chart.serviceAccountName" . }}
automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}

{{- /* ── Image pull secrets ─────────────────────────── */}}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}

{{- /* ── Pod security context ──────────────────────── */}}
{{- with .Values.podSecurityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}

{{- /* ── Termination & DNS ────────────────────────── */}}
terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds | default 30 }}
{{- if .Values.hostNetwork }}
hostNetwork: true
{{- end }}
{{- if .Values.hostIPC }}
hostIPC: true
{{- end }}
{{- if .Values.hostPID }}
hostPID: true
{{- end }}
{{- if .Values.shareProcessNamespace }}
shareProcessNamespace: true
{{- end }}
{{- with .Values.dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}
{{- with .Values.dnsConfig }}
dnsConfig:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.priorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with .Values.runtimeClassName }}
runtimeClassName: {{ . }}
{{- end }}
{{- with .Values.schedulerName }}
schedulerName: {{ . }}
{{- end }}
{{- with .Values.restartPolicy }}
restartPolicy: {{ . }}
{{- end }}
{{- with .Values.readinessGates }}
readinessGates:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.hostAliases }}
hostAliases:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.overhead }}
overhead:
  {{- toYaml . | nindent 2 }}
{{- end }}

{{- /* ── Init containers ──────────────────────────── */}}
{{- with .Values.initContainers }}
initContainers:
  {{- toYaml . | nindent 2 }}
{{- end }}

{{- /* ── Main container ───────────────────────────── */}}
containers:
  {{- include "universal-chart.mainContainer" . | nindent 2 }}
  {{- /* ── Sidecar containers ──────────────────────── */}}
  {{- with .Values.sidecars }}
  {{- toYaml . | nindent 2 }}
  {{- end }}

{{- /* ── Volumes ──────────────────────────────────── */}}
{{- with .Values.volumes }}
volumes:
  {{- toYaml . | nindent 2 }}
{{- end }}

{{- /* ── Scheduling ───────────────────────────────── */}}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}


{{/*
=============================================================================
MAIN CONTAINER — all possible container spec fields
=============================================================================
*/}}
{{- define "universal-chart.mainContainer" -}}
- name: {{ include "universal-chart.name" . }}
  image: {{ include "universal-chart.image" . }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}

  {{- with .Values.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.command }}
  command:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.args }}
  args:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.workingDir }}
  workingDir: {{ . }}
  {{- end }}

  {{- with .Values.ports }}
  ports:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.env }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.envFrom }}
  envFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.livenessProbe }}
  livenessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.readinessProbe }}
  readinessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.startupProbe }}
  startupProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.volumeMounts }}
  volumeMounts:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .Values.volumeDevices }}
  volumeDevices:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- if .Values.stdin }}
  stdin: true
  {{- end }}
  {{- if .Values.stdinOnce }}
  stdinOnce: true
  {{- end }}
  {{- if .Values.tty }}
  tty: true
  {{- end }}

  {{- with .Values.terminationMessagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with .Values.terminationMessagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}
{{- end }}


{{/*
=============================================================================
SHARED JOB POD SPEC — for CronJob / Job
=============================================================================
Call: {{- include "universal-chart.jobPodSpec" (dict "Values" $.Values "Chart" $.Chart "Release" $.Release "job" $job) }}
*/}}
{{- define "universal-chart.jobPodSpec" -}}
restartPolicy: {{ .job.restartPolicy | default "OnFailure" }}
serviceAccountName: {{ include "universal-chart.serviceAccountName" . }}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .job.initContainers }}
initContainers:
  {{- toYaml . | nindent 2 }}
{{- end }}
containers:
  - name: {{ .job.name }}
    image: {{ if .job.image }}{{ printf "%s:%s" .job.image.repository (.job.image.tag | default .Chart.AppVersion) }}{{ else }}{{ include "universal-chart.image" . }}{{ end }}
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    {{- with .job.command }}
    command:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .job.args }}
    args:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .job.env }}
    env:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .job.envFrom }}
    envFrom:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .job.resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .job.volumeMounts }}
    volumeMounts:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- with .job.sidecars }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- with .job.volumes }}
volumes:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
