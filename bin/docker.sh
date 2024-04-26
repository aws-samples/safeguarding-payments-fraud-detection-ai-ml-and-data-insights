#!/bin/bash

help()
{
  echo "Build image based on Dockerfile and push it to private container registry"
  echo
  echo "Syntax: docker.sh [-q|r|p|t|s|d|f]"
  echo "Options:"
  echo "q     Specify repository name (e.g. spf-fraud)"
  echo "r     Specify AWS region (e.g. us-east-1)"
  echo "p     Specify platform (e.g. linux/arm64)"
  echo "t     Specify version (e.g. latest)"
  echo "s     Specify CI/CD role name (e.g. spf-cicd-assume-role-abcd1234)"
  echo "d     Specify directory (e.g. app/fraud)"
  echo "f     Specify Dockerfile (e.g. Dockerfile)"
  echo
}

set -o pipefail

SPF_REPOSITORY=""
SPF_REGION=""
SPF_VERSION="latest"
SPF_PLATFORM="linux/arm64"
SPF_ROLE_NAME=""
DIRECTORY="app/fraud"
DOCKERFILE="Dockerfile"

while getopts "h:q:r:p:t:s:d:f:" option; do
  case $option in
    h)
      help
      exit;;
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
    d)
      DIRECTORY="$OPTARG";;
    f)
      DOCKERFILE="$OPTARG";;
    \?)
      echo "[ERROR] invalid option"
      echo
      help
      exit;;
  esac
done

aws --version > /dev/null 2>&1 || { pip install awscli; }
aws --version > /dev/null 2>&1 || { echo "[ERROR] aws is missing. aborting..."; exit 1; }
docker --version > /dev/null 2>&1 || { echo "[ERROR] docker is missing. aborting..."; exit 1; }

if [ -z "${SPF_ROLE_NAME}" ] && [ ! -z "${TF_VAR_ROLE_NAME}" ]; then SPF_ROLE_NAME="${TF_VAR_ROLE_NAME}"; fi
if [ -z "${SPF_REGION}" ] && [ ! -z "${TF_VAR_SPF_REGION}" ]; then SPF_REGION="${TF_VAR_SPF_REGION}"; fi
if [ -z "${SPF_REGION}" ] && [ ! -z "${AWS_DEFAULT_REGION}" ]; then SPF_REGION="${AWS_DEFAULT_REGION}"; fi
if [ -z "${SPF_REGION}" ] && [ ! -z "${AWS_REGION}" ]; then SPF_REGION="${AWS_REGION}"; fi

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

echo "[INFO] echo {\"credsStore\":\"ecr-login\"} > ${DOCKER_CONFIG}/config.json"
mkdir -p "${DOCKER_CONFIG}" && touch "${DOCKER_CONFIG}/config.json" && echo "{\"credsStore\":\"ecr-login\"}" > "${DOCKER_CONFIG}/config.json"

echo "[INFO] aws ecr get-login-password --region ${SPF_REGION} | docker login --username AWS --password-stdin ${ENDPOINT}"
aws ecr get-login-password --region "${SPF_REGION}" | docker login --username AWS --password-stdin "${ENDPOINT}" || { echo "[ERROR] docker login failed. aborting..."; exit 1; }

if [ ! -z "${SPF_ROLE_NAME}" ]; then
  echo "[INFO] aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${SPF_ROLE_NAME} --role-session-name ${ACCOUNT}"
  ASSUME_ROLE=$(aws sts assume-role --role-arn "arn:aws:iam::${ACCOUNT}:role/${SPF_ROLE_NAME}" --role-session-name "${ACCOUNT}")
  OPTIONS="${OPTIONS} --build-arg AWS_DEFAULT_REGION=${SPF_REGION}"
  OPTIONS="${OPTIONS} --build-arg AWS_ACCESS_KEY_ID=$(echo "${ASSUME_ROLE}" | jq -r '.Credentials.AccessKeyId')"
  OPTIONS="${OPTIONS} --build-arg AWS_SECRET_ACCESS_KEY=$(echo "${ASSUME_ROLE}" | jq -r '.Credentials.SecretAccessKey')"
  OPTIONS="${OPTIONS} --build-arg AWS_SESSION_TOKEN=$(echo "${ASSUME_ROLE}" | jq -r '.Credentials.SessionToken')"
fi

echo "[INFO] docker build -t ${SPF_REPOSITORY}:${SPF_VERSION} -f ${WORKDIR}/${DOCKERFILE} ${WORKDIR}/${DIRECTORY}/ --platform ${SPF_PLATFORM}"
docker build -t "${SPF_REPOSITORY}:${SPF_VERSION}" -f "${WORKDIR}/${DOCKERFILE}" "${WORKDIR}/${DIRECTORY}/" --platform "${SPF_PLATFORM}" ${OPTIONS} || { echo "[ERROR] docker build failed. aborting..."; exit 1; }

echo "[INFO] docker tag ${SPF_REPOSITORY}:${SPF_VERSION} ${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
docker tag "${SPF_REPOSITORY}:${SPF_VERSION}" "${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}" || { echo "[ERROR] docker tag failed. aborting..."; exit 1; }

echo "[INFO] docker push ${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}"
OUTPUT=$(docker push "${ENDPOINT}/${SPF_REPOSITORY}:${SPF_VERSION}") || { echo "[ERROR] docker push failed. aborting..."; exit 1; }

echo "[INFO] OUTPUT: ${OUTPUT}"
IFS=' ' read -ra ARR <<< "$(echo "${OUTPUT}" | tr '\n' ' ')"

# if [ ! -z "${UPDATE}" ] && [ "${UPDATE}" == "true" ]; then
#   echo "[INFO] aws lambda update-function-code --region ${SPF_REGION} --function-name ${SPF_REPOSITORY} --image-uri ${ENDPOINT}/${SPF_REPOSITORY}@${ARR[${#ARR[@]} - 3]}"
#   aws lambda update-function-code --region "${SPF_REGION}" --function-name "${SPF_REPOSITORY}" --image-uri "${ENDPOINT}/${SPF_REPOSITORY}@${ARR[${#ARR[@]} - 3]}"
# fi
