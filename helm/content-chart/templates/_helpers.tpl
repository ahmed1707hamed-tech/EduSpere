{{/*
Expand the name of the chart.
*/}}
{{- define "content-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "content-chart.fullname" -}}
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
{{- define "content-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "content-chart.labels" -}}
helm.sh/chart: {{ include "content-chart.chart" . }}
{{ include "content-chart.selectorLabels" . }}
app.kubernetes.io/component: backend
app.kubernetes.io/part-of: edusphere
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "content-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "content-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "content-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "content-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ConfigMap resource name
*/}}
{{- define "content-chart.configMapName" -}}
{{- .Values.config.name | default (printf "%s-config" (include "content-chart.fullname" .)) }}
{{- end }}

{{/*
Secret resource name
*/}}
{{- define "content-chart.secretName" -}}
{{- .Values.secret.name | default (printf "%s-secret" (include "content-chart.fullname" .)) }}
{{- end }}

{{/*
PersistentVolumeClaim name
*/}}
{{- define "content-chart.pvcName" -}}
{{- .Values.persistence.name | default (printf "%s-storage" (include "content-chart.fullname" .)) }}
{{- end }}
