# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM public.ecr.aws/docker/library/postgres:16

# RUN apt install -y postgresql-common
# RUN install -d /usr/share/postgresql-common/pgdg
# RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
# RUN apt install -y curl ca-certificates
# RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt update
# RUN apt install -y postgresql-16-pgvector
