#!/bin/bash

help()
{
  echo "Deploy AWS resource using Terraform and Terragrunt"
  echo
  echo "Syntax: deploy.sh [-a|b|c|d|i|r|t]"
  echo "Options:"
  echo "a     Specify AWS application ARN (e.g. arn:aws:resource-groups:us-east-1:123456789012:group/SPF/abcd1234)"
  echo "b     Specify Terraform backend config (e.g. {\"us-east-1\"=\"spf-backend-us-east-1\"})"
  echo "c     Specify cleanup / destroy resources (e.g. true)"
  echo "d     Specify directory (e.g. iac/cicd)"
  echo "i     Specify global id (e.g. abcd1234)"
  echo "r     Specify AWS region (e.g. us-east-1)"
  echo "t     Specify S3 bucket (e.g. spf-backend-us-east-1)"
  echo
}

set -o pipefail

SPF_APP_ARN=""
SPF_REGION=""
SPF_BUCKET=""
SPF_BACKEND=""
SPF_GID=""
SPF_DIR="iac/cicd"
# SPF_VPC_ID=""
# SPF_VPCE_SERVICES=""
# SPF_VPC_SUBNETS_CREATE="false"
# SPF_VPC_SUBNETS_SOURCE="availability_zones"
# SPF_VPC_SUBNETS_AZS=""
# SPF_VPC_SUBNETS_WZS=""
CLEANUP=""

while getopts "h:a:b:c:d:i:r:t:" option; do
  case $option in
    h)
      help
      exit;;
    a)
      SPF_APP_ARN="$OPTARG";;
    b)
      SPF_BACKEND="$OPTARG";;
    c)
      CLEANUP="$OPTARG";;
    d)
      SPF_DIR="$OPTARG";;
    i)
      SPF_GID="$OPTARG";;
    r)
      SPF_REGION="$OPTARG";;
    t)
      SPF_BUCKET="$OPTARG";;
    \?)
      echo "[ERROR] invalid option"
      echo
      help
      exit;;
  esac
done

aws --version > /dev/null 2>&1 || { echo "[ERROR] aws is missing. aborting..."; exit 1; }
terraform -version > /dev/null 2>&1 || { echo "[ERROR] terraform is missing. aborting..."; exit 1; }
terragrunt -version > /dev/null 2>&1 || { echo "[ERROR] terragrunt is missing. aborting..."; exit 1; }

if [ -z "${SPF_REGION}" ] && [ -n "${AWS_DEFAULT_REGION}" ]; then SPF_REGION="${AWS_DEFAULT_REGION}"; fi
if [ -z "${SPF_REGION}" ] && [ -n "${AWS_REGION}" ]; then SPF_REGION="${AWS_REGION}"; fi

if [ -z "${SPF_REGION}" ]; then
  echo "[DEBUG] SPF_REGION: ${SPF_REGION}"
  echo "[ERROR] SPF_REGION is missing..."; exit 1;
fi

if [ -z "${SPF_BUCKET}" ]; then
  echo "[DEBUG] SPF_BUCKET: ${SPF_BUCKET}"
  echo "[ERROR] SPF_BUCKET is missing..."; exit 1;
fi

if [ -z "${SPF_BACKEND}" ]; then
  SPF_BACKEND={\"${SPF_REGION}\"=\"${SPF_BUCKET}\"}
fi

WORKDIR="$( cd "$(dirname "$0")/../" > /dev/null 2>&1 || exit 1; pwd -P )"
OPTIONS="-var backend_bucket=${SPF_BACKEND}"

if [ -n "${SPF_GID}" ]; then
  OPTIONS="${OPTIONS} -var spf_gid=${SPF_GID}"
fi

if [ -n "${SPF_ACCOUNT}" ]; then
  OPTIONS="${OPTIONS} -var account=${SPF_ACCOUNT}"
fi

if [ -n "${SPF_APP_ARN}" ]; then
  OPTIONS="${OPTIONS} -var app_arn=${SPF_APP_ARN}"
fi

if [ -n "${SPF_VPC_ID}" ]; then
  OPTIONS="${OPTIONS} -var vpc_id=${SPF_VPC_ID}"
fi

if [ -n "${SPF_VPCE_SERVICES}" ]; then
  OPTIONS="${OPTIONS} -var vpce_services=${SPF_VPCE_SERVICES}"
fi

if [ -n "${SPF_VPC_SUBNETS_CREATE}" ]; then
  OPTIONS="${OPTIONS} -var vpc_subnets_create=${SPF_VPC_SUBNETS_CREATE}"
fi

if [ -n "${SPF_VPC_SUBNETS_SOURCE}" ]; then
  OPTIONS="${OPTIONS} -var vpc_subnets_source=${SPF_VPC_SUBNETS_SOURCE}"
fi

if [ -n "${SPF_VPC_SUBNETS_WZS}" ]; then
  OPTIONS="${OPTIONS} -var vpc_subnets_wzs=${SPF_VPC_SUBNETS_WZS}"
fi

if [ ! -d "${WORKDIR}/${SPF_DIR}/" ]; then
  echo "[DEBUG] SPF_DIR: ${SPF_DIR}"
  echo "[ERROR] ${WORKDIR}/${SPF_DIR}/ does not exist..."; exit 1;
fi

echo "[EXEC] cd ${WORKDIR}/${SPF_DIR}/"
cd "${WORKDIR}/${SPF_DIR}/"

echo "[EXEC] terragrunt run-all init -backend-config region=${SPF_REGION} -backend-config bucket=${SPF_BUCKET}"
terragrunt run-all init -backend-config region="${SPF_REGION}" -backend-config="bucket=${SPF_BUCKET}" || { echo "[ERROR] terragrunt run-all init failed. aborting..."; cd -; exit 1; }

if [ -n "${CLEANUP}" ] && [ "${CLEANUP}" == "true" ]; then
  echo "[EXEC] terragrunt run-all destroy -auto-approve -var-file default.tfvars ${OPTIONS}"
  echo "Y" | terragrunt run-all destroy -auto-approve -var-file default.tfvars ${OPTIONS} || { echo "[ERROR] terragrunt run-all destroy failed. aborting..."; cd -; exit 1; }
else
  echo "[EXEC] terragrunt run-all apply -auto-approve -var-file default.tfvars ${OPTIONS}"
  echo "Y" | terragrunt run-all apply -auto-approve -var-file default.tfvars ${OPTIONS} || { echo "[ERROR] terragrunt run-all apply failed. aborting..."; cd -; exit 1; }
fi

echo "[EXEC] cd -"
cd -
