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
  echo "d     Specify directory (e.g. app/fraud)"
  echo "f     Specify Dockerfile (e.g. Dockerfile)"
  echo "q     Specify repository name (e.g. spf-fraud)"
  echo "r     Specify AWS region (e.g. us-east-1)"
  echo "p     Specify platform (e.g. linux/amd64)"
  echo "t     Specify version (e.g. latest)"
  echo "s     Specify CI/CD role name (e.g. spf-cicd-assume-role-abcd1234)"
  echo
}

set -o pipefail

DIRECTORY="app/fraud"
DOCKERFILE="Dockerfile"
SPF_ROLE_NAME=""
SPF_PLATFORM="linux/amd64"
SPF_VERSION="latest"

while getopts "h:d:f:q:r:p:t:s:" option; do
  case $option in
    h)
      help
      exit;;
    d)
      DIRECTORY="$OPTARG";;
    f)
      DOCKERFILE="$OPTARG";;
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

DOCKERDIR="$( cd "${WORKDIR}/${DIRECTORY}/" > /dev/null 2>&1 || exit 1; pwd -P )"
while [ "${DOCKERDIR}" != "${WORKDIR}" ] && [ ! -f "${DOCKERDIR}/${DOCKERFILE}" ]; do
  DOCKERDIR="$( cd "${DOCKERDIR}/../" > /dev/null 2>&1 || exit 1; pwd -P )"
done

echo "[EXEC] docker buildx build -t ${SPF_REPOSITORY}:${SPF_VERSION} -f ${DOCKERDIR}/${DOCKERFILE} ${WORKDIR}/${DIRECTORY}/ --platform ${SPF_PLATFORM}"
docker buildx build -t "${SPF_REPOSITORY}:${SPF_VERSION}" -f "${DOCKERDIR}/${DOCKERFILE}" "${WORKDIR}/${DIRECTORY}/" --platform "${SPF_PLATFORM}" ${OPTIONS} || { echo "[ERROR] docker build failed. aborting..."; exit 1; }

echo "[EXEC] docker buildx tag ${SPF_REPOSITORY}:${SPF_VERSION} ${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
docker buildx tag "${SPF_REPOSITORY}:${SPF_VERSION}" "${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}" || { echo "[ERROR] docker tag failed. aborting..."; exit 1; }

echo "[EXEC] docker buildx push ${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
docker buildx push "${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
# OUTPUT=$(docker push "${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}") || { echo "[ERROR] docker push failed. aborting..."; exit 1; }

# echo "[INFO] OUTPUT: ${OUTPUT}"
# IFS=' ' read -ra ARR <<< "$(echo "${OUTPUT}" | tr '\n' ' ')"
