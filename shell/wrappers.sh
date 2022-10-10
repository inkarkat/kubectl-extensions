#!/bin/sh source-this-script

kubectl()
{
    let _kubectl_use+=1
    kubectl-wrapper "$@"
}
