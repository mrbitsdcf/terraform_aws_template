#!/bin/bash

# Author: MrBiTs (mrbits@mrbits.com.br)
# Creation Date: 2021-12-05 (Stardate 99527.37)
# Last Modification Date: 2022-10-18 (Stardate 100395.73)
#
# Script to destroy AWS infrastructure created by terraform
#
# AWS credentials must be already set.

. ./lib/common.sh

stty -echoctl

trap 'ctrl_c' INT HUP QUIT TSTP

ctrl_c () {
    echo "NOT ALLOWED"
}

nuke_them_all () {
    date_msg "Cleaning up main project"
    rm -rf .terraform .terraform.lock.hcl
    terraform init
    terraform plan -out tfplan -destroy
    terraform apply -auto-approve tfplan

    date_msg "Cleaning up Remote States"
    cd remote_state
    rm -rf .terraform .terraform.lock.hcl
    terraform init
    terraform plan -out tfplan -destroy
    terraform apply -auto-approve tfplan

    date_msg "Removing S3 bucket for remote state"
    BUCKET_NAME=$(cat .remote_state_bucket)
    aws s3 rb s3://${BUCKET_NAME}

    date_msg "Cleaning up dynamic providers and backends"
    rm -f remote_state.tf backend.tf providers.tf .remote_state_bucket
    cd ..
    rm -f main.tf backend.tf providers.tf

    date_msg "Environment destroyed"
}

date_msg "Cleaning up AWS environment"

echo -e "${bold}${bgRed8}${fgWhite8}###################################################${color_reset}"
echo -e "${bold}${bgRed8}${fgWhite8}# WARNING WARNING WARNING WARNING WARNING WARNING #${color_reset}"
echo -e "${bold}${bgRed8}${fgWhite8}#  THIS SCRIPT WILL DESTROY ALL YOUR ENVIRONMENT  #${color_reset}"
echo -e "${bold}${bgRed8}${fgWhite8}# WARNING WARNING WARNING WARNING WARNING WARNING #${color_reset}"
echo -e "${bold}${bgRed8}${fgWhite8}###################################################${color_reset}"
echo -e ${color_reset}

read -p "Are you sure? (y/n) " -r -n 1 yn
echo
echo

case $yn in
    y )
        date_msg "Destroying environment"
        nuke_them_all
        exit 0
        ;;
    n )
        date_msg "Cleanup cancelled by user"
        exit
        ;;
    * )
        date_msg "Invalid response. Exiting"
        exit 1
        ;;
esac
