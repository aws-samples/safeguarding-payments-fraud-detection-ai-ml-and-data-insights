#!/bin/bash

help()
{
  echo "Deploy cloud resource using AWS CLI, Kubectl, Terraform and Terragrunt"
  echo
  echo "Syntax: deploy.sh [-a|b|c|d|e|i|r|t]"
  echo "Options:"
  echo "a     Specify AWS application ARN (e.g. arn:aws:resource-groups:us-east-1:123456789012:group/SPF/abcd1234)"
  echo "b     Specify Terraform backend config (e.g. {\"us-east-1\"=\"spf-backend-us-east-1\"})"
  echo "c     Specify cleanup / destroy resources (e.g. true)"
  echo "d     Specify directory path (e.g. iac/core)"
  echo "e     Specify ECR repository prefix (e.g. spf-iac-core)"
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

WORKDIR="$( cd "$(dirname "$0")/../" > /dev/null 2>&1 || exit 1; pwd -P )"
if [ ! -d "${WORKDIR}/${SPF_DIR}/" ]; then
  echo "[DEBUG] SPF_DIR: ${SPF_DIR}"
  echo "[ERROR] ${WORKDIR}/${SPF_DIR}/ does not exist..."; exit 1;
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

  aws --version > /dev/null 2>&1 || { wget -q https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip; unzip awscli-exe-linux-aarch64.zip; sudo ./aws/install; ln -s /usr/local/bin/aws ${WORKDIR}/bin/aws; }
  kubectl version --client > /dev/null 2>&1 || { wget -q https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl; chmod 0755 kubectl; mv kubectl ${WORKDIR}/bin/kubectl; }

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
    SPF_ECR_URI=$(echo "${SPF_RESULT}" | jq -r ".repository.repositoryName")
  else
    SPF_ECR_URI=$(echo "${SPF_RESULT}" | jq -r ".[0].repositoryName")
  fi

  echo "[EXEC] ${WORKDIR}/bin/docker.sh -q ${SPF_ECR_NAME} -r ${SPF_REGION} -d ${SPF_DIR}"
  ${WORKDIR}/bin/docker.sh -q ${SPF_ECR_NAME} -r ${SPF_REGION} -d ${SPF_DIR} || { echo "[ERROR] docker script failed. aborting..."; exit 1; }

  K8SDIR=${WORKDIR}/${SPF_DIR}/k8s
  if [ -d "${K8SDIR}" ]; then
    if [ -n "${SPF_EKS_NAME}" ]; then
      echo "[EXEC] aws eks update-kubeconfig --region ${SPF_REGION} --name ${SPF_EKS_NAME}"
      aws eks update-kubeconfig --region ${SPF_REGION} --name ${SPF_EKS_NAME} || { echo "[ERROR] aws eks update-kubeconfig failed. aborting..."; exit 1; }
    fi

    if [ -z "${SPF_ECR_NAME}" ]; then
      echo "[EXEC] kubectl create namespace "${SPF_ECR_NAME}" --dry-run=client -o yaml | kubectl apply -f -"
      kubectl create namespace "${SPF_ECR_NAME}" --dry-run=client -o yaml | kubectl apply -f -

      echo "[EXEC] kubectl config set-context --current --namespace=${SPF_ECR_NAME}"
      kubectl config set-context --current --namespace=${SPF_ECR_NAME}
    fi

    export SPF_ECR_URI="${SPF_ECR_URI}"
    export SPF_ECR_NAME="${SPF_ECR_NAME}"
    echo "[EXEC] env > ${K8SDIR}/config.txt"
    env > ${K8SDIR}/config.txt

    for i in "${K8SDIR}"/*; do
      if [ "${i: -4}" == ".tpl" ]; then
        echo "[EXEC] ${WORKDIR}/bin/templater.sh ${i} -f ${K8SDIR}/config.txt -s > ${i/.tpl/.yml}"
        ${WORKDIR}/bin/templater.sh ${i} -f ${K8SDIR}/config.txt -s > ${i/.tpl/.yml}
        i=${i/.tpl/.yml}
      fi

      if [ "${i: -4}" == ".yml" ] || [ "${i: -5}" == ".yaml" ]; then
        echo "[EXEC] kubectl apply -f ${i}"
        kubectl apply -f ${i}
        sleep 5
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

  terraform -v > /dev/null 2>&1 || { wget -q https://releases.hashicorp.com/terraform/1.8.3/terraform_1.8.3_linux_arm64.zip; unzip terraform_*.zip; mv terraform ${WORKDIR}/bin/terraform; }
  terragrunt -v > /dev/null 2>&1 || { wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.58.4/terragrunt_linux_arm64; chmod 0755 terragrunt_*; mv terragrunt_* ${WORKDIR}/bin/terragrunt; }

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
