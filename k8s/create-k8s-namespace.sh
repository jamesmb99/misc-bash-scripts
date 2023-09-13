#!/bin/bash

#########################################
# script to create a kubernetes namespace
# in the current namespace.
##########################################

################### usage ############################
# ./ create-k8s-namespace.sh <name you want to give the namespace>

k=kubectl
new_namespace=$1
current_context=$($k config current-context)

read -p "creating a new namespace in the $current_context context proceed(y/n)?": decision

# Check the user's decision
if [ "$decision" = "y" ] || [ "$decision" = "Y" ]; then
    # create name space
    echo "Installing new namespace"
    $k create namespace $new_namespace
    echo "new namespace $new_namespace created"
else
    echo "namespace creation canceled"
fi
