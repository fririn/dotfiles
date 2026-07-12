#!/bin/sh
# waybar custom/kubernetes
# Native rewrite of /usr/libexec/i3blocks/kubernetes for waybar
# (fixes that script's jsonpath field-casing bug: kubeconfig JSON keys are
# lowercase, so `.Contexts` never actually matched anything).

command -v kubectl >/dev/null 2>&1 || exit 0

CTX=$(kubectl config current-context 2>/dev/null)
[ -z "$CTX" ] && exit 0

NS=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\"$CTX\")].context.namespace}" 2>/dev/null)

printf '{"text":"☸ %s/%s ☸","class":"k8s"}\n' "$CTX" "$NS"
