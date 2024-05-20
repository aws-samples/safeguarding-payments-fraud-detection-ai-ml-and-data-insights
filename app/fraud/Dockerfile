# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM public.ecr.aws/docker/library/python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY payments_worker.py .

CMD [ "python", "-u", "./payments_worker.py" ]
