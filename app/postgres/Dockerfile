# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM public.ecr.aws/docker/library/postgres:16

# ARG SPF_DOCKERFILE_DBHOST=${SPF_DOCKERFILE_DBHOST:-"localhost"}
# ARG SPF_DOCKERFILE_DBNAME=${SPF_DOCKERFILE_DBNAME:-"payments"}
# ARG SPF_DOCKERFILE_DBUSER=${SPF_DOCKERFILE_DBUSER:-"payments"}
# ARG SPF_DOCKERFILE_DBPASS=${SPF_DOCKERFILE_DBPASS:-""}
# ARG SPF_DOCKERFILE_DBPORT=${SPF_DOCKERFILE_DBPORT:-"5432"}

# ENV POSTGRES_DB ${SPF_DOCKERFILE_DBNAME}
# ENV POSTGRES_USER ${SPF_DOCKERFILE_DBHOST}
# ENV POSTGRES_PASSWORD $(echo -n "${SPF_DOCKERFILE_DBPASS}" | base64 --decode)
# ENV PGPASSWORD $(echo -n "${SPF_DOCKERFILE_DBPASS}" | base64 --decode)

COPY init.sql /docker-entrypoint-initdb.d/

RUN apt update -y
RUN apt install -y postgresql-common ca-certificates curl
RUN install -d /usr/share/postgresql-common/pgdg
RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN echo -ne "\n" | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
RUN apt update -y
RUN apt install -y postgresql-16-pgvector

# RUN touch ${HOME}/.pgpass && cat "${SPF_DOCKERFILE_DBHOST}:${SPF_DOCKERFILE_DBPORT}:${SPF_DOCKERFILE_DBNAME}:${SPF_DOCKERFILE_DBUSER}:${SPF_DOCKERFILE_DBPASS}" > ${HOME}/.pgpass
# RUN psql -d "${SPF_DOCKERFILE_DBNAME}" -h "${SPF_DOCKERFILE_DBHOST}" -p "${SPF_DOCKERFILE_DBPORT}" -U "${SPF_DOCKERFILE_DBUSER}" -w -a -f initdb.sql
