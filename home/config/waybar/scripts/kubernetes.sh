#!/bin/sh
command -v kubectl >/dev/null 2>&1 || exit 0

CTX=$(kubectl config current-context 2>/dev/null)
[ -z "$CTX" ] && exit 0

NS=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\"$CTX\")].context.namespace}" 2>/dev/null)

# Strip noisy "pinniped" segments, e.g. "prod-eu-pinniped" -> "prod-eu"
filter() {
    printf '%s' "$1" | sed -E 's/-?pinniped-?//g'
}
CTX=$(filter "$CTX")
NS=$(filter "$NS")

printf '{"text":" %s/%s","class":"k8s"}\n' "$CTX" "$NS"
