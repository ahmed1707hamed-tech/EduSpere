{{- define "postgres-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "postgres-chart.fullname" -}}
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

{{- define "postgres-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "postgres-chart.labels" -}}
helm.sh/chart: {{ include "postgres-chart.chart" . }}
{{ include "postgres-chart.selectorLabels" . }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: edusphere
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "postgres-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgres-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "postgres-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "postgres-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "postgres-chart.configMapName" -}}
{{- .Values.config.name | default (printf "%s-init" (include "postgres-chart.fullname" .)) }}
{{- end }}

{{- define "postgres-chart.secretName" -}}
{{- .Values.secret.name | default (printf "%s-secret" (include "postgres-chart.fullname" .)) }}
{{- end }}

{{- define "postgres-chart.pvcName" -}}
{{- .Values.persistence.name | default (printf "%s-pvc" (include "postgres-chart.fullname" .)) }}
{{- end }}

{{- define "postgres-chart.storageClass" -}}
{{- if .Values.persistence.storageClass }}
{{- .Values.persistence.storageClass }}
{{- else if and .Values.global .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- end }}
{{- end }}
