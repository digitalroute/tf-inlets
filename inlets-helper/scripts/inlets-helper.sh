#!/usr/bin/env sh

if [ "$1" = "helper" ]; then
  shift
  inlets client --remote="$INL_REMOTE_URI" $@
else
  inlets $@
fi
