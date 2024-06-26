# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM public.ecr.aws/lambda/python:3.12-arm64 AS base

ENV LANG=en_US.UTF-8 \
    TZ=:/etc/localtime \
    LAMBDA_TASK_ROOT=/var/task \
    LAMBDA_RUNTIME_DIR=/var/runtime \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=120

WORKDIR ${LAMBDA_TASK_ROOT}

ENV VIRTUAL_ENV=${LAMBDA_TASK_ROOT}/venv \
    PYTHONPATH=${PYTHONPATH}:${LAMBDA_TASK_ROOT} \
    LD_LIBRARY_PATH=/var/lang/lib:/lib64:/usr/lib64:/opt/lib:${LAMBDA_RUNTIME_DIR}:${LAMBDA_RUNTIME_DIR}/lib:${LAMBDA_TASK_ROOT}:${LAMBDA_TASK_ROOT}/lib

ENV PATH=${VIRTUAL_ENV}/bin:/var/lang/bin:/usr/local/bin:/usr/bin/:/bin:/opt/bin:${PATH}

RUN dnf update -y && dnf clean all

COPY . .

RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

CMD [ "lambda_function.lambda_handler" ]

#checkov:skip=CKV_DOCKER_2:Skip health check
#checkov:skip=CKV_DOCKER_3:Skip user control
