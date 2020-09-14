-----------------------------------------
Generate shell command for initContainers
-----------------------------------------

{{- define "mongoose.makeShellCommand" -}}

    {{- range $index, $e := until (.Values.replicas|int) -}}
        {{- printf "\n\t\t" -}}
        {{- printf `while [ $( curl -s -o /dev/null -w "%{http_code}" ` -}}
        {{- printf "http://%s-worker-%d.%s.svc.cluster.local:%d" $.Values.name $index $.Values.service.name $.Release.Namespace 1099 -}}
        {{- printf ") -ne 52]; do sleep 3; done;" -}}
    {{- end -}}

{{- end }}
