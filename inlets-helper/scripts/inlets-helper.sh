#!/usr/bin/env sh

token_arg=""
if [ ! -z "$INL_TOKEN" ]; then
  token_arg="--token=$INL_TOKEN"
fi

if [ "$1" = "helper" ]; then
  shift
  inlets client --remote="$INL_REMOTE_URI" "$token_arg" $@
else
  inlets "$token_arg" $@
fi
