#!/bin/bash
#
# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

help()
{
  echo "Deploy cloud resource using AWS CLI, Kubectl, Terraform and Terragrunt"
  echo
  echo "Syntax: deploy.sh [-a|b|c|d|e|i|r|t]"
  echo "Options:"
  echo "a     Specify AWS application ARN (e.g. arn:aws:resource-groups:us-east-1:123456789012:group/spf/abcd1234)"
  echo "b     Specify Terraform backend config (e.g. {\"us-east-1\"=\"spf-backend-us-east-1\"})"
  echo "c     Specify cleanup / destroy resources (e.g. true)"
  echo "d     Specify directory path (e.g. app/postgres)"
  echo "e     Specify ECR repository prefix (e.g. spf-app-postgres)"
  echo "i     Specify global id (e.g. abcd1234)"
  echo "r     Specify AWS region (e.g. us-east-1)"
  echo "s     Specify S3 bucket (e.g. spf-backend-us-east-1)"
  echo
}

set -o pipefail

while getopts "h:a:b:c:d:e:i:r:s:" option; do
  case $option in
    h)
      help
      exit;;
    a)
      SPF_APP_ARN="$OPTARG";;
    b)
      SPF_BACKEND="$OPTARG";;
    c)
      SPF_CLEANUP="$OPTARG";;
    d)
      SPF_DIR="$OPTARG";;
    e)
      SPF_ECR="$OPTARG";;
    i)
      SPF_GID="$OPTARG";;
    r)
      SPF_REGION="$OPTARG";;
    s)
      SPF_BUCKET="$OPTARG";;
    \?)
      echo "[ERROR] invalid option"
      echo
      help
      exit;;
  esac
done

if [ -z "${SPF_REGION}" ] && [ -n "${AWS_DEFAULT_REGION}" ]; then SPF_REGION="${AWS_DEFAULT_REGION}"; fi
if [ -z "${SPF_REGION}" ] && [ -n "${AWS_REGION}" ]; then SPF_REGION="${AWS_REGION}"; fi

if [ -z "${SPF_REGION}" ]; then
  echo "[DEBUG] SPF_REGION: ${SPF_REGION}"
  echo "[ERROR] SPF_REGION is missing..."; exit 1;
fi

if [ -z "${SPF_DIR}" ]; then
  echo "[DEBUG] SPF_DIR: ${SPF_DIR}"
  echo "[ERROR] SPF_DIR is missing..."; exit 1;
fi

# aws --version > /dev/null 2>&1 || { wget -q https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip; unzip awscli-exe-linux-aarch64.zip; sudo ./aws/install; ln -s /usr/local/bin/aws ${WORKDIR}/bin/aws; }
# jq --version > /dev/null 2>&1 || { wget -q https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64; chmod 0755 jq-*; mv jq-* ${WORKDIR}/bin/jq; }
aws --version > /dev/null 2>&1 || { wget -q https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip; unzip awscli-exe-linux-x86_64.zip; sudo ./aws/install --bin-dir ${WORKDIR}/bin --install-dir ${WORKDIR}/awscli; }
jq --version > /dev/null 2>&1 || { wget -q https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-i386; chmod 0755 jq-*; mv jq-* ${WORKDIR}/bin/jq; }

WORKDIR="$( cd "$(dirname "$0")/../" > /dev/null 2>&1 || exit 1; pwd -P )"
if [ ! -d "${WORKDIR}/${SPF_DIR}/" ]; then
  echo "[DEBUG] SPF_DIR: ${SPF_DIR}"
  echo "[ERROR] ${WORKDIR}/${SPF_DIR}/ does not exist..."; exit 1;
fi

SPF_SECRET="spf-secrets-deploy-${SPF_REGION}"
if [ -n "${SPF_GID}" ]; then
  SPF_SECRET="${SPF_SECRET}-${SPF_GID}"
fi
SPF_QUERY="SecretList[?Name==\`${SPF_SECRET}\`]"

echo "[EXEC] aws secretsmanager list-secrets --region ${SPF_REGION} --query ${SPF_QUERY}"
SPR_RESULT=$(aws secretsmanager list-secrets --region ${SPF_REGION} --query ${SPF_QUERY})

if [ "${SPF_RESULT}" != "[]" ]; then
  echo "[EXEC] aws secretsmanager get-secret-value --region ${SPF_REGION} --secret-id ${SPF_SECRET} --query SecretString"
  SPF_RESULT=$(aws secretsmanager get-secret-value --region ${SPF_REGION} --secret-id ${SPF_SECRET} --query SecretString)

  case ${SPF_RESULT} in \"{*)
    SPF_RESULT=$(echo "${SPF_RESULT}" | jq -r '.')
    SPF_KEYS=( $(echo "${SPF_RESULT}" | jq -r 'keys[]') )
    SPF_VALUES=( $(echo "${SPF_RESULT}" | jq -r 'values[]') )
    for i in "${!SPF_KEYS[@]}"; do
      export ${SPF_KEYS[i]}="${SPF_VALUES[i]}"
    done
  esac
fi

case ${SPF_DIR} in app*)
  echo "
  ##############################################################
  # Deployment Process for Application Code                    #
  # 1. create ECR repository if missing (aws cli)              #
  # 2. build image and push to ECR (docker cli)                #
  # 3. run kubectl on manifest yaml files (leverage templates) #
  ##############################################################
  "

  # kubectl version --client > /dev/null 2>&1 || { wget -q https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl; chmod 0755 kubectl; mv kubectl ${WORKDIR}/bin/kubectl; }
  kubectl version --client > /dev/null 2>&1 || { wget -q https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl; chmod 0755 kubectl; mv kubectl ${WORKDIR}/bin/kubectl; }

  if [ -n "${SPF_ECR}" ]; then
    SPF_ECR_NAME="${SPF_ECR}"
  else
    SPF_ECR_NAME="spf-${SPF_DIR//\//-}"
  fi

  if [ -n "${SPF_REGION}" ]; then
    SPF_ECR_NAME="${SPF_ECR_NAME}-${SPF_REGION}"
  fi

  if [ -n "${SPF_GID}" ]; then
    SPF_ECR_NAME="${SPF_ECR_NAME}-${SPF_GID}"
  fi

  SPF_QUERY="repositories[?repositoryName==\`${SPF_ECR_NAME}\`]"
  echo "[EXEC] aws ecr describe-repositories --region ${SPF_REGION} --query ${SPF_QUERY}"
  SPF_RESULT=$(aws ecr describe-repositories --region ${SPF_REGION} --query ${SPF_QUERY})

  if [ "${SPF_RESULT}" == "[]" ]; then
    echo "[EXEC] aws ecr create-repository --region ${SPF_REGION} --repository-name ${SPF_ECR_NAME}"
    SPF_RESULT=$(aws ecr create-repository --region ${SPF_REGION} \
      --repository-name ${SPF_ECR_NAME} \
      --image-tag-mutability MUTABLE \
      --image-scanning-configuration scanOnPush=true \
      --encryption-configuration encryptionType=KMS
    )
    SPF_ECR_URI=$(echo "${SPF_RESULT}" | jq -r ".repository.repositoryUri")
  else
    SPF_ECR_URI=$(echo "${SPF_RESULT}" | jq -r ".[0].repositoryUri")
  fi

  if [ -n "${SPF_EKS_ARCH}" ] && [ "${SPF_EKS_ARCH}" == "arm" ]; then
    SPF_PLATFORM="linux/arm64"
  else
    SPF_PLATFORM="linux/x86_64"
  fi

  if [ -z "${SPF_CLEANUP}" ] || [ "${SPF_CLEANUP}" != "true" ]; then
    echo "[EXEC] ${WORKDIR}/bin/docker.sh -q ${SPF_ECR_NAME} -r ${SPF_REGION} -d ${SPF_DIR} -p ${SPF_PLATFORM}"
    ${WORKDIR}/bin/docker.sh -q ${SPF_ECR_NAME} -r ${SPF_REGION} -d ${SPF_DIR} -p ${SPF_PLATFORM} || { echo "[ERROR] docker script failed. aborting..."; exit 1; }
  fi

  K8SDIR=${WORKDIR}/${SPF_DIR}/k8s
  if [ -d "${K8SDIR}" ]; then
    if [ -n "${SPF_EKS_CLUSTER_NAME}" ]; then
      echo "[EXEC] aws eks update-kubeconfig --region ${SPF_REGION} --name ${SPF_EKS_CLUSTER_NAME}"
      aws eks update-kubeconfig --region ${SPF_REGION} --name ${SPF_EKS_CLUSTER_NAME} || { echo "[ERROR] aws eks update-kubeconfig failed. aborting..."; exit 1; }
    fi

    if [ -n "${SPF_ECR_NAME}" ]; then
      echo "[EXEC] kubectl create namespace "${SPF_ECR_NAME}" --dry-run=client -o yaml | kubectl apply -f -"
      kubectl create namespace "${SPF_ECR_NAME}" --dry-run=client -o yaml | kubectl apply -f - || { echo "[ERROR] kubectl create namespace failed. aborting..."; exit 1; }

      echo "[EXEC] kubectl config set-context --current --namespace=${SPF_ECR_NAME}"
      kubectl config set-context --current --namespace=${SPF_ECR_NAME} || { echo "[ERROR] kubectl config set-context failed. aborting..."; exit 1; }
    fi

    export SPF_ECR_URI="${SPF_ECR_URI}"
    export SPF_ECR_NAME="${SPF_ECR_NAME}"
    echo "[EXEC] env | grep SPF_" > ${K8SDIR}/config.txt
    env | grep SPF_ > ${K8SDIR}/config.txt

    for i in "${K8SDIR}"/*; do
      if [ "${i: -4}" == ".tpl" ]; then
        echo "[EXEC] ${WORKDIR}/bin/templater.sh ${i} -f ${K8SDIR}/config.txt -s > ${i/.tpl/.yml}"
        ${WORKDIR}/bin/templater.sh ${i} -f ${K8SDIR}/config.txt -s > ${i/.tpl/.yml}
        i=${i/.tpl/.yml}
        # echo "[DEBUG] cat ${i}"
        # cat ${i}
      fi

      if [ "${i: -4}" == ".yml" ] || [ "${i: -5}" == ".yaml" ]; then
        if [ -n "${SPF_CLEANUP}" ] && [ "${SPF_CLEANUP}" == "true" ]; then
          echo "[EXEC] kubectl delete -f ${i}"
          kubectl delete -f ${i} || { echo "[ERROR] kubectl delete failed. aborting..."; exit 1; }
        else
          echo "[EXEC] kubectl apply -f ${i}"
          kubectl apply -f ${i} || { echo "[ERROR] kubectl apply failed. aborting..."; exit 1; }
          sleep 5
        fi
      fi
    done
  fi
esac

case ${SPF_DIR} in iac*)
  echo "
  #################################################################
  # Deployment Process for Infrastructure as Code                 #
  # 1. pass specific environment variables as terraform variables #
  # 2. run terragrunt commands across specific directory          #
  #################################################################
  "

  # terraform -v > /dev/null 2>&1 || { wget -q https://releases.hashicorp.com/terraform/1.8.3/terraform_1.8.3_linux_arm64.zip; unzip terraform_*.zip; mv terraform ${WORKDIR}/bin/terraform; }
  # terragrunt -v > /dev/null 2>&1 || { wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.58.4/terragrunt_linux_arm64; chmod 0755 terragrunt_*; mv terragrunt_* ${WORKDIR}/bin/terragrunt; }
  terraform -v > /dev/null 2>&1 || { wget -q https://releases.hashicorp.com/terraform/1.8.3/terraform_1.8.3_linux_386.zip; unzip terraform_*.zip; mv terraform ${WORKDIR}/bin/terraform; }
  terragrunt -v > /dev/null 2>&1 || { wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.58.4/terragrunt_linux_386; chmod 0755 terragrunt_*; mv terragrunt_* ${WORKDIR}/bin/terragrunt; }

  if [ -z "${SPF_BUCKET}" ]; then
    echo "[DEBUG] SPF_BUCKET: ${SPF_BUCKET}"
    echo "[ERROR] SPF_BUCKET is missing..."; exit 1;
  fi

  if [ -z "${SPF_BACKEND}" ]; then
    SPF_BACKEND={\"${SPF_REGION}\"=\"${SPF_BUCKET}\"}
  fi

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

  if [ -n "${SPF_EKS_CLUSTER_NAME}" ]; then
    OPTIONS="${OPTIONS} -var eks_cluster_name=${SPF_EKS_CLUSTER_NAME}"
  fi

  if [ -n "${SPF_EKS_NODE_TYPE}" ]; then
    OPTIONS="${OPTIONS} -var eks_node_type=${SPF_EKS_NODE_TYPE}"
  fi

  if [ -n "${SPF_EKS_NODE_ARCH}" ]; then
    OPTIONS="${OPTIONS} -var eks_node_arch=${SPF_EKS_NODE_ARCH}"
  fi

  if [ -n "${SPF_EKS_NODE_EC2}" ]; then
    OPTIONS="${OPTIONS} -var eks_node_ec2=${SPF_EKS_NODE_EC2}"
  fi

  if [ -n "${SPF_EKS_NODE_EBS}" ]; then
    OPTIONS="${OPTIONS} -var eks_node_ebs=${SPF_EKS_NODE_EBS}"
  fi

  if [ -n "${SPF_VPC_ID}" ]; then
    OPTIONS="${OPTIONS} -var vpc_id=${SPF_VPC_ID}"
  fi

  if [ -n "${SPF_VPCE_MAPPING}" ]; then
    OPTIONS="${OPTIONS} -var vpce_mapping=${SPF_VPCE_MAPPING}"
  fi

  if [ -n "${SPF_SUBNETS_IGW_CREATE}" ]; then
    OPTIONS="${OPTIONS} -var subnets_igw_create=${SPF_SUBNETS_IGW_CREATE}"
  fi

  if [ -n "${SPF_SUBNETS_IGW_MAPPING}" ]; then
    OPTIONS="${OPTIONS} -var subnets_igw_mapping=${SPF_SUBNETS_IGW_MAPPING}"
  fi

  if [ -n "${SPF_SUBNETS_NAT_CREATE}" ]; then
    OPTIONS="${OPTIONS} -var subnets_nat_create=${SPF_SUBNETS_NAT_CREATE}"
  fi

  if [ -n "${SPF_SUBNETS_NAT_MAPPING}" ]; then
    OPTIONS="${OPTIONS} -var subnets_nat_mapping=${SPF_SUBNETS_NAT_MAPPING}"
  fi

  if [ -n "${SPF_SUBNETS_CAGW_CREATE}" ]; then
    OPTIONS="${OPTIONS} -var subnets_cagw_create=${SPF_SUBNETS_CAGW_CREATE}"
  fi

  if [ -n "${SPF_SUBNETS_CAGW_MAPPING}" ]; then
    OPTIONS="${OPTIONS} -var subnets_cagw_mapping=${SPF_SUBNETS_CAGW_MAPPING}"
  fi

  echo "[EXEC] cd ${WORKDIR}/${SPF_DIR}/"
  cd "${WORKDIR}/${SPF_DIR}/"

  echo "[EXEC] terragrunt run-all init -backend-config region=${SPF_REGION} -backend-config bucket=${SPF_BUCKET}"
  terragrunt run-all init -backend-config region="${SPF_REGION}" -backend-config="bucket=${SPF_BUCKET}" || { echo "[ERROR] terragrunt run-all init failed. aborting..."; cd -; exit 1; }

  if [ -n "${SPF_CLEANUP}" ] && [ "${SPF_CLEANUP}" == "true" ]; then
    echo "[EXEC] terragrunt run-all destroy -auto-approve -var-file default.tfvars ${OPTIONS}"
    echo "Y" | terragrunt run-all destroy -auto-approve -var-file default.tfvars ${OPTIONS} || { echo "[ERROR] terragrunt run-all destroy failed. aborting..."; cd -; exit 1; }
  else
    echo "[EXEC] terragrunt run-all apply -auto-approve -var-file default.tfvars ${OPTIONS}"
    echo "Y" | terragrunt run-all apply -auto-approve -var-file default.tfvars ${OPTIONS} || { echo "[ERROR] terragrunt run-all apply failed. aborting..."; cd -; exit 1; }
  fi

  echo "[EXEC] cd -"
  cd -
esac
