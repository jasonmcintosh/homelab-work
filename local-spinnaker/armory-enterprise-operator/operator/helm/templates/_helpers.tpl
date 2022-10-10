{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "spinnaker-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
Longest append adds 18 characters, so truncate to 45 (63-18) because some
Kubernetes name fields are limited to 63 characters (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spinnaker-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 45 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s" $name | trunc 45 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Fullname suffixed with "-operator" */}}
{{- define "spinnaker-operator.operator.fullname" -}}
{{- printf "%s-operator" (include "spinnaker-operator.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with "-halyard" */}}
{{- define "spinnaker-operator.halyard.fullname" -}}
{{- printf "%s-halyard" (include "spinnaker-operator.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with "-spinnaker-service" */}}
{{- define "spinnaker-operator.spinnaker-service.fullname" -}}
{{- printf "%s-spinnaker-service" (include "spinnaker-operator.fullname" .) -}}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "spinnaker-operator.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "spinnaker-operator.labels" }}
chart: {{ template "spinnaker-operator.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.spinnakerOperator.commonLabels}}
{{ toYaml .Values.spinnakerOperator.commonLabels }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spinnaker-operator.operator.serviceAccountName" -}}
  {{ default "spinnaker-operator" .Values.spinnakerOperator.serviceAccount.name }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spinnaker-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "spinnaker-operator.labels-placeholder" -}}
app.kubernetes.io/name: {{ include "spinnaker-operator.name" . }}
helm.sh/chart: {{ include "spinnaker-operator.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
