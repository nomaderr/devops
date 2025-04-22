{{/* Chart-wide labels */}}
{{- define "fleet.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Full name for main app (Fleet) */}}
{{- define "fleet.fullname" -}}
{{ .Release.Name }}-fleet
{{- end }}

{{/* Full name for MySQL */}}
{{- define "fleet.mysql.fullname" -}}
{{ .Release.Name }}-mysql
{{- end }}

{{/* Full name for Redis */}}
{{- define "fleet.redis.fullname" -}}
{{ .Release.Name }}-redis
{{- end }}

{{/* Name of secret used for MySQL */}}
{{- define "fleet.mysql.secretName" -}}
{{ .Release.Name }}-mysql-secret
{{- end }}

{{/* PVC name for MySQL */}}
{{- define "fleet.mysql.pvc" -}}
{{ .Release.Name }}-mysql-pvc
{{- end }}
