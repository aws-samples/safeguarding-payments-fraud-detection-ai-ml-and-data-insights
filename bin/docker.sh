#!/bin/bash
#
# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

help()
{
  echo "Build image based on Dockerfile and push it to private container registry"
  echo
  echo "Syntax: docker.sh [-d|f|q|r|p|t|s]"
  echo "Options:"
  echo "d     Specify directory (e.g. app/postgres)"
  echo "f     Specify Dockerfile (e.g. Dockerfile)"
  echo "q     Specify repository name (e.g. spf-app-postgres)"
  echo "r     Specify AWS region (e.g. us-east-1)"
  echo "p     Specify platform (e.g. linux/x86_64)"
  echo "t     Specify version (e.g. latest)"
  echo "s     Specify CI/CD role name (e.g. spf-cicd-assume-role)"
  echo
}

set -o pipefail

DOCKERFILE="Dockerfile"
SPF_DIR="app/postgres"
SPF_PLATFORM="linux/x86_64"
SPF_VERSION="latest"

while getopts "h:d:f:q:r:p:t:s:" option; do
  case $option in
    h)
      help
      exit;;
    f)
      DOCKERFILE="$OPTARG";;
    d)
      SPF_DIR="$OPTARG";;
    q)
      SPF_REPOSITORY="$OPTARG";;
    r)
      SPF_REGION="$OPTARG";;
    p)
      SPF_PLATFORM="$OPTARG";;
    t)
      SPF_VERSION="$OPTARG";;
    s)
      SPF_ROLE_NAME="$OPTARG";;
    \?)
      echo "[ERROR] invalid option"
      echo
      help
      exit;;
  esac
done

aws --version > /dev/null 2>&1 || { echo "[ERROR] aws is missing. aborting..."; exit 1; }
docker --version > /dev/null 2>&1 || { echo "[ERROR] docker is missing. aborting..."; exit 1; }
jq --version > /dev/null 2>&1 || { echo "[ERROR] jq is missing. aborting..."; exit 1; }

if [ -z "${SPF_ROLE_NAME}" ] && [ -n "${TF_VAR_ROLE_NAME}" ]; then SPF_ROLE_NAME="${TF_VAR_ROLE_NAME}"; fi
if [ -z "${SPF_REGION}" ] && [ -n "${TF_VAR_SPF_REGION}" ]; then SPF_REGION="${TF_VAR_SPF_REGION}"; fi
if [ -z "${SPF_REGION}" ] && [ -n "${AWS_DEFAULT_REGION}" ]; then SPF_REGION="${AWS_DEFAULT_REGION}"; fi
if [ -z "${SPF_REGION}" ] && [ -n "${AWS_REGION}" ]; then SPF_REGION="${AWS_REGION}"; fi

if [ -z "${SPF_REGION}" ]; then
  echo "[DEBUG] SPF_REGION: ${SPF_REGION}"
  echo "[ERROR] SPF_REGION is missing. aborting..."; exit 1;
fi

if [ -z "${SPF_REPOSITORY}" ]; then
  echo "[DEBUG] SPF_REPOSITORY: ${SPF_REPOSITORY}"
  echo "[ERROR] SPF_REPOSITORY is missing. aborting..."; exit 1;
fi

if [ -z "${SPF_VERSION}" ]; then
  echo "[DEBUG] SPF_VERSION: ${SPF_VERSION}"
  echo "[ERROR] SPF_VERSION is missing. aborting..."; exit 1;
fi

if [ -z "${SPF_PLATFORM}" ]; then
  echo "[DEBUG] SPF_PLATFORM: ${SPF_PLATFORM}"
  echo "[ERROR] SPF_PLATFORM is missing. aborting..."; exit 1;
fi

WORKDIR="$( cd "$(dirname "$0")/../" > /dev/null 2>&1 || exit 1; pwd -P )"
ACCOUNT=$(aws sts get-caller-identity --query Account --region "${SPF_REGION}")
ACCOUNT=${ACCOUNT//\"/}
ENDPOINT="${ACCOUNT}.dkr.ecr.${SPF_REGION}.amazonaws.com"
DOCKER_CONFIG="${WORKDIR}/.docker"
OPTIONS=""

echo "[EXEC] echo {\"credsStore\":\"ecr-login\"} > ${DOCKER_CONFIG}/config.json"
mkdir -p "${DOCKER_CONFIG}" && touch "${DOCKER_CONFIG}/config.json" && echo "{\"credsStore\":\"ecr-login\"}" > "${DOCKER_CONFIG}/config.json"

echo "[EXEC] aws ecr get-login-password --region ${SPF_REGION} | docker login --username AWS --password-stdin ${ENDPOINT}"
aws ecr get-login-password --region "${SPF_REGION}" | docker login --username AWS --password-stdin "${ENDPOINT}" || { echo "[ERROR] docker login failed. aborting..."; exit 1; }

if [ -n "${SPF_ROLE_NAME}" ]; then
  echo "[EXEC] aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${SPF_ROLE_NAME} --role-session-name ${ACCOUNT}"
  ASSUME_ROLE=$(aws sts assume-role --role-arn "arn:aws:iam::${ACCOUNT}:role/${SPF_ROLE_NAME}" --role-session-name "${ACCOUNT}")
  OPTIONS="${OPTIONS} --build-arg AWS_DEFAULT_REGION=${SPF_REGION}"
  OPTIONS="${OPTIONS} --build-arg AWS_ACCESS_KEY_ID=$(echo "${ASSUME_ROLE}" | jq -r '.Credentials.AccessKeyId')"
  OPTIONS="${OPTIONS} --build-arg AWS_SECRET_ACCESS_KEY=$(echo "${ASSUME_ROLE}" | jq -r '.Credentials.SecretAccessKey')"
  OPTIONS="${OPTIONS} --build-arg AWS_SESSION_TOKEN=$(echo "${ASSUME_ROLE}" | jq -r '.Credentials.SessionToken')"
fi

SPF_DOCKERFILE_ARRAY=$(env | grep ".*SPF_DOCKERFILE_.*" | awk -F "=" '{print $1}')
if [ -n "${SPF_DOCKERFILE_ARRAY}" ]; then
IFS='
'
  for i in ${SPF_DOCKERFILE_ARRAY}; do
    OPTIONS="${OPTIONS} --build-arg ${i}=${!i}"
  done
unset IFS
fi

DOCKERDIR="$( cd "${WORKDIR}/${SPF_DIR}/" > /dev/null 2>&1 || exit 1; pwd -P )"
while [ "${DOCKERDIR}" != "${WORKDIR}" ] && [ ! -f "${DOCKERDIR}/${DOCKERFILE}" ]; do
  DOCKERDIR="$( cd "${DOCKERDIR}/../" > /dev/null 2>&1 || exit 1; pwd -P )"
done

if [ -f "${DOCKERDIR}/.dockerdependencies" ]; then
  for i in $(cat ${DOCKERDIR}/.dockerdependencies); do
    while IFS="," read -r SPF_IMAGE_SOURCE SPF_IMAGE_TARGET; do
      SPF_QUERY="repositories[?repositoryName==\`${SPF_IMAGE_TARGET}\`]"
      echo "[EXEC] aws ecr describe-repositories --region ${SPF_REGION} --query ${SPF_QUERY}"
      SPF_RESULT=$(aws ecr describe-repositories --region ${SPF_REGION} --query ${SPF_QUERY})

      if [ "${SPF_RESULT}" == "[]" ]; then
        echo "[EXEC] aws ecr create-repository --region ${SPF_REGION} --repository-name ${SPF_IMAGE_TARGET}"
        SPF_RESULT=$(aws ecr create-repository --region ${SPF_REGION} \
          --repository-name ${SPF_IMAGE_TARGET} \
          --image-tag-mutability MUTABLE \
          --image-scanning-configuration scanOnPush=true \
          --encryption-configuration encryptionType=KMS
        )
      fi

      echo "[EXEC] docker pull ${SPF_IMAGE_SOURCE}"
      docker pull ${SPF_IMAGE_SOURCE} || { echo "[ERROR] docker pull ${SPF_IMAGE_SOURCE} failed. aborting..."; exit 1; }

      echo "[EXEC] docker tag ${SPF_IMAGE_SOURCE} ${ENDPOINT}/${SPF_IMAGE_TARGET}:${SPF_VERSION}"
      docker tag ${SPF_IMAGE_SOURCE} ${ENDPOINT}/${SPF_IMAGE_TARGET}:${SPF_VERSION}  || { echo "[ERROR] docker tag ${SPF_IMAGE_SOURCE} failed. aborting..."; exit 1; }

      echo "[EXEC] docker push ${ENDPOINT}/${SPF_IMAGE_TARGET}:${SPF_VERSION}"
      docker push ${ENDPOINT}/${SPF_IMAGE_TARGET}:${SPF_VERSION} || { echo "[ERROR] docker push ${SPF_IMAGE_TARGET} failed. aborting..."; exit 1; }
    done <<< "${i}"
  done
fi

SPF_QUERY="repositories[?repositoryName==\`${SPF_REPOSITORY}\`]"
echo "[EXEC] aws ecr describe-repositories --region ${SPF_REGION} --query ${SPF_QUERY}"
SPF_RESULT=$(aws ecr describe-repositories --region ${SPF_REGION} --query ${SPF_QUERY})

if [ "${SPF_RESULT}" == "[]" ]; then
  echo "[EXEC] aws ecr create-repository --region ${SPF_REGION} --repository-name ${SPF_REPOSITORY}"
  SPF_RESULT=$(aws ecr create-repository --region ${SPF_REGION} \
    --repository-name ${SPF_REPOSITORY} \
    --image-tag-mutability MUTABLE \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=KMS
  )
fi

echo "[EXEC] docker buildx build --platform ${SPF_PLATFORM} -f ${DOCKERDIR}/${DOCKERFILE} -t ${SPF_REPOSITORY}:${SPF_VERSION} ${WORKDIR}/${SPF_DIR}/"
docker buildx build ${OPTIONS} --platform "${SPF_PLATFORM}" -f "${DOCKERDIR}/${DOCKERFILE}" -t "${SPF_REPOSITORY}:${SPF_VERSION}" "${WORKDIR}/${SPF_DIR}/" || { echo "[ERROR] docker build failed. aborting..."; exit 1; }

echo "[EXEC] docker tag ${SPF_REPOSITORY}:${SPF_VERSION} ${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
docker tag "${SPF_REPOSITORY}:${SPF_VERSION}" "${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}" || { echo "[ERROR] docker tag failed. aborting..."; exit 1; }

echo "[EXEC] docker push ${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
docker push "${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
