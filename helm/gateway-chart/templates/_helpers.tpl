{{- define "gateway-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gateway-chart.fullname" -}}
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

{{- define "gateway-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gateway-chart.labels" -}}
helm.sh/chart: {{ include "gateway-chart.chart" . }}
{{ include "gateway-chart.selectorLabels" . }}
app.kubernetes.io/component: gateway
app.kubernetes.io/part-of: edusphere
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "gateway-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gateway-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "gateway-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gateway-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "gateway-chart.configMapName" -}}
{{- .Values.config.name | default (printf "%s-config" (include "gateway-chart.fullname" .)) }}
{{- end }}

{{- define "gateway-chart.secretName" -}}
{{- .Values.secret.name | default (printf "%s-secret" (include "gateway-chart.fullname" .)) }}
{{- end }}
