#!/bin/bash
until kubectl get pods "$1" -n "$2" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -m 1 "True"; do
  echo "Waiting for pod $1 to be ready..."
  sleep 3
#kubernetes How to wait for a pod to be ready to use (with examples) 
done
echo "Pod $1 is ready!"