apiVersion: apps/v1
kind: Deployment # Create a deployment
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres # Set the name of the deployment
spec:
  replicas: 1 # Set deployment replicas
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:14-alpine # Docker image
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 5432 # Exposing the container port 5432 for PostgreSQL client connections.
          env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_USER
                  optional:
                    false # same as default; "postgres-secret" must exist
                    # and include a key named "username"
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_PASSWORD
                  optional:
                    false # same as default; "postgres-secret" must exist
                    # and include a key named "password"
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
      volumes:
        - name: postgres-data
          persistentVolumeClaim:
            claimName: postgres-pv-claim
