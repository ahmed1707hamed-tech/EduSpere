{{- define "minio-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "minio-chart.fullname" -}}
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

{{- define "minio-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "minio-chart.labels" -}}
helm.sh/chart: {{ include "minio-chart.chart" . }}
{{ include "minio-chart.selectorLabels" . }}
app.kubernetes.io/component: storage
app.kubernetes.io/part-of: edusphere
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "minio-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "minio-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "minio-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "minio-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "minio-chart.secretName" -}}
{{- .Values.secret.name | default (printf "%s-secret" (include "minio-chart.fullname" .)) }}
{{- end }}

{{- define "minio-chart.pvcName" -}}
{{- .Values.persistence.name | default (printf "%s-pvc" (include "minio-chart.fullname" .)) }}
{{- end }}

{{- define "minio-chart.storageClass" -}}
{{- if .Values.persistence.storageClass }}
{{- .Values.persistence.storageClass }}
{{- else if and .Values.global .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- end }}
{{- end }}
