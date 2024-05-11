apiVersion: batch/v1
kind: CronJob
metadata:
  name: spf-data-collector
  namespace: spf-data-collector-app
  labels:
    app: spf-data-collector-image
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
         labels:
          job: spf-data-collector-job
        spec:
          containers:
          - image: {{SPF_ECR_URI}}:latest
            name: spf-data-collector-image
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
