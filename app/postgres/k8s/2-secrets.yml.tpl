apiVersion: v1
kind: Secret
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres-secret
type: Opaque
data:
  POSTGRES_DB: {{SPF_POSTGRES_DB}}
  POSTGRES_USER: {{SPF_POSTGRES_USER}}
  POSTGRES_PASSWORD: {{SPF_POSTGRES_PASSWORD}}
