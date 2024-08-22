# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: batch/v1
kind: CronJob
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: data-collector
  labels:
    app: data-collector-app
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
          - name: data-collector-app
            image: {{SPF_ECR_URI}}:latest
            command: ["java"]
            args: ["-jar", "/app/runner.jar"]
            ports:
            - containerPort: 8080
            volumeMounts:
              - name: data
                mountPath: /data
            env:
            - name: FILE_DATA_EXTRACT_FOLDER_IN_S3
              valueFrom:
                configMapKeyRef:
                  name: data-collector-config
                  key: file_data_extract_folder_in_s3
            - name: FILE_LINE_NUMBER_TO_READ_FROM
              valueFrom:
                configMapKeyRef:
                  name: data-collector-config
                  key: file_line_number_to_read_from
            - name: FILES_LOCATION_IN_S3
              valueFrom:
                configMapKeyRef:
                  name: data-collector-config
                  key: files_location_in_s3
            - name: MAX_LINES_TO_READ
              valueFrom:
                configMapKeyRef:
                  name: data-collector-config
                  key: max_lines_to_read
            - name: PAYMENT_DATA_FILE
              valueFrom:
                configMapKeyRef:
                  name: data-collector-config
                  key: payment_data
            - name: S3_BUCKET
              valueFrom:
                configMapKeyRef:
                  name: data-collector-config
                  key: s3_bucket
            - name: MINIO_HOST
              valueFrom:
                secretKeyRef:
                  name: minio-secret
                  key: host
            - name: MINIO_USERNAME
              valueFrom:
                secretKeyRef:
                  name: minio-secret
                  key: username
            - name: MINIO_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: minio-secret
                  key: password
            resources:
          restartPolicy: OnFailure
          volumes:
          - name: data
            emptyDir:
              sizeLimit: 500Mi   
