{{/*
Expand the name of the chart.
*/}}
{{- define "edusphere.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "edusphere.fullname" -}}
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
{{- define "edusphere.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "edusphere.labels" -}}
helm.sh/chart: {{ include "edusphere.chart" . }}
{{ include "edusphere.selectorLabels" . }}
app.kubernetes.io/part-of: edusphere
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "edusphere.selectorLabels" -}}
app.kubernetes.io/name: {{ include "edusphere.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ConfigMap resource name
*/}}
{{- define "edusphere.configMapName" -}}
{{- .Values.config.name | default (printf "%s-config" (include "edusphere.fullname" .)) }}
{{- end }}

{{/*
Secret resource name
*/}}
{{- define "edusphere.secretName" -}}
{{- .Values.secret.name | default (printf "%s-secret" (include "edusphere.fullname" .)) }}
{{- end }}
