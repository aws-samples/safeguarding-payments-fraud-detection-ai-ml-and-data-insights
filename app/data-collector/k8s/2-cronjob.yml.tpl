# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: batch/v1
kind: CronJob
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: data-collector
  labels:
    app: data-collector-image
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
         labels:
          job: data-collector-job
        spec:
          serviceAccountName: service-account
          containers:
          - image: {{SPF_ECR_URI}}:latest
            name: data-collector-image
            command: ["java"]
            args: ["-jar", "/app/runner.jar"]
            ports:
            - containerPort: 8080
            volumeMounts:
              - name: data
                mountPath: /data
            resources:
          restartPolicy: OnFailure
          volumes:
          - name: data
            emptyDir:
              sizeLimit: 500Mi   
