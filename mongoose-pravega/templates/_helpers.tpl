-----------------------------------------
Generate shell command for initContainers
-----------------------------------------
*/}}
{{- define "mongoose.makeShellCommand" -}}
{{- $nodeCount := ((add (.Values.replicas|int) -1)|int) -}}
{{- if gt $nodeCount 0 -}}
    {{- range $index, $e := until $nodeCount -}}
        {{- printf "\n\t\t" -}}
        {{- printf `while [ $( curl -s -o /dev/null -w "%{http_code}" ` -}}
        {{- printf "http://%s-%d.%s:%d/config" $.Values.pod.name $index $.Values.service.name 9999 -}}
        {{- printf ") -ne 200]; do sleep 3; done;" -}}
    {{- end -}}
{{- else }}
    {{- print " " }}
{{- end }}
{{- end }}
