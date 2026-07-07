{{/*
Expand the name of the chart.
*/}}
{{- define "quiz-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "quiz-chart.fullname" -}}
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
{{- define "quiz-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quiz-chart.labels" -}}
helm.sh/chart: {{ include "quiz-chart.chart" . }}
{{ include "quiz-chart.selectorLabels" . }}
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
{{- define "quiz-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quiz-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quiz-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quiz-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ConfigMap resource name
*/}}
{{- define "quiz-chart.configMapName" -}}
{{- .Values.config.name | default (printf "%s-config" (include "quiz-chart.fullname" .)) }}
{{- end }}

{{/*
Secret resource name
*/}}
{{- define "quiz-chart.secretName" -}}
{{- .Values.secret.name | default (printf "%s-secret" (include "quiz-chart.fullname" .)) }}
{{- end }}
