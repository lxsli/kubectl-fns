#!/bin/bash

set -eu
set -o pipefail

args="";
if (( ${#*} > 0 )); then
    op="$1"; shift
    case "$op" in
        del | rm) op='delete';;
        kill) op='delete'; args="--force --grace-period=0";;
        g) op='get';;
        d | desc) op='describe';;
        tail) op='logs'; set -- --tail=10 --follow "$@";;
        tail0) op='logs'; set -- --tail=0 --follow "$@";;
        scale0) op='scale'; args="--replicas=0";;
        scale1) op='scale'; args="--replicas=1";;
        scale3) op='scale'; args="--replicas=3";;
    esac
fi

if (( ${#*} > 0 )); then
    kind="$1"; shift
    case "$kind" in
        dep) kind='deploy';;
    esac
fi

set -- ${op:+"$op"} ${kind:+"$kind"} "$@"
if [[ -z "${KUBE_NS:-}" ]]; then
    kubectl $args "$@"
else
    kubectl -n "$KUBE_NS" $args "$@"
fi
