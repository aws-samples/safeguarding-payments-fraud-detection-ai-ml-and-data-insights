# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#
# Build stage
#
# FROM maven AS build
FROM public.ecr.aws/docker/library/maven:amazoncorretto AS build
ENV WORKDIR=/usr/app
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR
ADD . $WORKDIR
RUN --mount=type=cache,target=/root/.m2 mvn -f $WORKDIR/pom.xml clean compile assembly:single

#
# Package stage
#
FROM public.ecr.aws/amazoncorretto/amazoncorretto:22-headless
ARG JAR_FILE=/usr/app/target/*.jar
COPY --from=build $JAR_FILE /app/runner.jar
RUN mkdir /root/.aws
ADD credentials /root/.aws
EXPOSE 8080
ENTRYPOINT java -jar /app/runner.jar
