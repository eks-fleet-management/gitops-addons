{{/*
Expand the name of the chart. Defaults to `.Chart.Name` or `nameOverride`.
*/}}
{{- define "application-sets.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate a fully qualified app name.
If `fullnameOverride` is defined, it uses that; otherwise, it constructs the name based on `Release.Name` and chart name.
*/}}
{{- define "application-sets.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (default .Chart.Name .Values.nameOverride) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version, useful for labels.
*/}}
{{- define "application-sets.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels for the ApplicationSet, including version and managed-by labels.
*/}}
{{- define "application-sets.labels" -}}
helm.sh/chart: {{ include "application-sets.chart" . }}
app.kubernetes.io/name: {{ include "application-sets.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Template to generate pod-identity configuration
*/}}
{{- define "application-sets.pod-identity" -}}
{{- $addonName := .addonName -}}
{{- $addonConfig := .addonConfig -}}
- repoURL: '{{`{{ .metadata.annotations.addons_repo_url }}`}}'
  targetRevision: '{{`{{ .metadata.annotations.addons_repo_revision }}`}}'
  path: 'charts/pod-identity'
  helm:
    releaseName: {{ $addonConfig.chartName | default $addonName | quote }}
    valuesObject:
      create: {{ $addonConfig.enableACK }}
      region: '{{`{{ .metadata.annotations.aws_region }}`}}'
      accountId: '{{`{{ .metadata.annotations.aws_account_id}}`}}'
      podIdentityAssociation:
        clusterName: '{{`{{ .metadata.annotations.aws_cluster_name }}`}}'
        namespace: '{{ default $addonConfig.namespace .namespace }}'
    ignoreMissingValueFiles: true
    valueFiles:
      - $values/{{`{{ .metadata.annotations.addons_repo_basepath }}`}}{{`{{ .metadata.labels.tenant }}`}}/default/addons/{{ $addonConfig.chartName | default $addonName }}/pod-identity/values.yaml
      - $values/{{`{{ .metadata.annotations.addons_repo_basepath }}`}}{{`{{ .metadata.labels.tenant }}`}}/clusters/{{`{{ .name }}`}}/addons/{{ $addonConfig.chartName | default $addonName }}/pod-identity/values.yaml
{{- end }}