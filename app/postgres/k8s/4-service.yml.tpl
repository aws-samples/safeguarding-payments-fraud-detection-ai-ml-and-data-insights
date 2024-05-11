apiVersion: v1
kind: Service # Create service
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres # Sets the service name
  labels:
    app: postgres # Defines app to create service for
spec:
  #type:  # Sets the service type
  ports:
    - protocol: TCP
      port: 35432
      targetPort: 5432
  selector:
    app: postgres
