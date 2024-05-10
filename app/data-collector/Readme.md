**Push image to ECR**
1. Ensure repo is created. For example - payment-fraud-app

Execute - 
- docker build -t payment-fraud-app --platform linux/amd64 .
- docker tag payment-fraud-app:latest public.ecr.aws/s5s3y9s1/payment-fraud-app:latest
- docker push public.ecr.aws/s5s3y9s1/payment-fraud-app:latest


Run the cron job for data collector - 
In EKS Cluster - 
1. cd app/data-collector/eks 
2. kubectl apply -f data-collector-cron.yaml

    This will run the data collector job on every 5th minute of every hour. If there are not new items to process, the job completes without processing anything.