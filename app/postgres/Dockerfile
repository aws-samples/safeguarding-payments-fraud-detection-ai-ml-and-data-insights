# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM public.ecr.aws/docker/library/postgres:16

ARG DBHOST=${DBHOST:-"localhost"}
ARG DBPORT=${DBPORT:-"5432"}
ARG DBNAME=${DBNAME:-"payments"}
ARG DBUSER=${DBUSER:-"payments"}
ARG DBPASS=${DBPASS:-""}

RUN apt update -y
RUN apt install -y postgresql-common ca-certificates curl
RUN install -d /usr/share/postgresql-common/pgdg
RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN echo -ne "\n" | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
RUN apt update -y
RUN apt install -y postgresql-16-pgvector

COPY initdb.sql .
ENV PGPASSWORD=${DBPASS}
RUN psql -d "${DBNAME}" -h "${DBHOST}" -p "${DBPORT}" -U "${DBUSER}" -w -a -f initdb.sql
