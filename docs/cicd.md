# CI/CD Pipeline

## Getting Started

This solution is designed to be flexible and robust with modular code stored
across the following directories:

1. `iac/` - Infrastructure as Code
    * `iac/cicd/` - CI/CD Pipeline Module
    * `iac/core/` - Core Infrastructure Module
    * `iac/quicksight/` - QuickSight Infrastructure Module
2. `app/` - Application Code
    * `app/anomaly-detector/` - Anomaly Detector Microservice (Python-based Module)
    * `app/data-collector/` - Data Collector Microservice (Java-based Module)
    * `app/minio/` - MinIO S3 API-Compatible Storage (Local to the Kubernetes Cluster)
    * `app/postgres/` - PostgreSQL Database (Local to the Kubernetes Cluster)

## Deploy CI/CD Module

Starting at the ROOT level of this repository, run the following command:

```sh
/bin/bash ./bin/deploy.sh -d iac/cicd -r us-east-1 -s spf-backend-us-east-1
```

> REMINDER: Make sure to replace *us-east-1* with your target AWS region and
*spf-backend-us-east-1* with your S3 bucket.

Once the build execution is successful, you should be able to login to
[AWS Management Console](https://console.aws.amazon.com/console/home), navigate to
[AWS CodeBuild](https://us-west-2.console.aws.amazon.com/codesuite/codebuild/projects)
service and see the newly created project named something like
*spf-cicd-pipeline-abcd1234*.

As an alternative, using AWS CLI, run the following command to retrieve
AWS CodeBuild project details:

```sh
aws codebuild list-projects --region us-east-1 \
    --query 'projects[?contains(@, `spf-cicd-pipeline`) == `true`]'
```

> REMINDER: Make sure to replace *us-east-1* with your target AWS region.

The suffix *abcd1234* in your AWS CodeBuild project name is the solution
deployment ID. This value can be used to test this solution, once deployed
successfully.

## Deploy Any Module

The CI/CD pipeline can be used to deploy any module (including itself, although
not recommended). The order of operations for entire solution deployment is:

1. In previous steps we deployed `iac/cicd` (CI/CD module)
2. After done with `iac/cicd`, deploy `iac/core` (Core module)
3. After done with `iac/cicd` and `iac/core`, deploy any other Infrastructure
modules from `iac/` directory (e.g. `iac/quicksight`)
4. After done with Infrastructure modules, deploy any dependencies required by
Application modules from `app/` directory (e.g. `app/postgres`)
5. After done with Application dependencies, deploy any other Application
modules from `app/` directory (e.g. `app/anomaly-detector` or
`app/data-collector`)

To pick which module to deploy (e.g. `app/postgres`), simply pass the
directory relative path value to `SPF_DIR` environment variable as shown below:

```sh
aws codebuild start-build --region us-east-1 \
    --project-name spf-cicd-pipeline-abcd1234 \
    --environment-variables-override "name=SPF_DIR,value=app/postgres"
```

## Environment Variables

The CI/CD pipeline provides a list of environment variables to make it easier
to deploy both AWS resources and Kubernetes resources using the same process:

Name | Default Value | Description
-----|---------------|------------
AWS_DEFAULT_REGION | us-east-1 | (Required) AWS Region used by Java or Python SDK
AWS_REGION | us-east-1 | (Required) AWS Region used by AWS CLI
SPF_REGION | us-east-1 | (Required) AWS Region used by Terraform
SPF_DIR | iac/core | (Required) Path to module where App or IaC code is
SPF_GID | | (Optional) Global ID appended to AWS resource names (e.g. abcd1234)
SPF_BUCKET | spf-backend-us-east-1 | (Required) S3 bucket used by Terraform to store .tfstate files
SPF_TFVAR_BACKEND_BUCKET | {"us-east-1"="spf-backend-us-east-1"} | (Optional) Terraform construct used to initialize S3 as backend
SPF_TFVAR_ACCOUNT | | (Optional) Allowed AWS account ID (or IDs, separated by comma)
SPF_TFVAR_APP_ARN | | (Optional) AWS myApplication ARN (e.g. arn:{{partition}}:resource-groups:{{region_name}}:{{account_id}}:group/{{app_id}})
SPF_TFVAR_APP_NAME | | (Optional) AWS myApplication Name (e.g. spf)
SPF_TFVAR_EKS_CLUSTER_NAME | | (Optional) EKS cluster name (e.g. spf-eks-cluster-us-east-1-abcd1234)
SPF_TFVAR_EKS_ACCESS_ROLES | | (Optional) EKS admin roles (e.g. {{role_name1}},{{role_name1}})
SPF_TFVAR_EKS_NODE_TYPE | self-managed | (Required) EKS node type (e.g. eks-managed, or fargate, or self-managed)
SPF_TFVAR_EKS_NODE_ARCH | x86 | (Required) EKS node architecture (e.g. x86, or arm, or amd)
SPF_TFVAR_EKS_NODE_EC2 | t3.medium | (Required) EKS node family (one or many, separated by comma)
SPF_TFVAR_EKS_NODE_EBS | gp2 | (Required) EKS node disk (e.g. gp2, or gp3)
SPF_TFVAR_S3_ENDPOINT_URL | | (Optional) S3 Endpoint URL (used in case of MinIO based deployment)
SPF_TFVAR_VPC_ID | | (Optional) VPC ID (must already exist, otherwise falls back to the default vpc)
SPF_TFVAR_VPCE_MAPPING | | (Optional) VPC endpoints mapping (e.g. {{interface_name}},{{interface_name}}:{{gateway_name}},{{gateway_name}})
SPF_TFVAR_SUBNETS_IGW_CREATE | false | (Optional) Create public subnets (if true, otherwise reuse the existing ones)
SPF_TFVAR_SUBNETS_NAT_CREATE | false | (Optional) Create private subnets (if true, otherwise reuse the existing ones)
SPF_TFVAR_SUBNETS_CAGW_CREATE | false | (Optional) Create wavelength subnets (if true, otherwise reuse the existing ones)
SPF_TFVAR_SUBNETS_IGW_MAPPING | | (Optional) Public subnets mapping (e.g. {{availability_zone_id}}:{{availability_zone_cidr}},{{local_zone_id}}:{{local_zone_cidr}})
SPF_TFVAR_SUBNETS_NAT_MAPPING | | (Optional) Private subnets mapping (e.g. {{availability_zone_id}}:{{availability_zone_cidr}},{{local_zone_id}}:{{local_zone_cidr}})
SPF_TFVAR_SUBNETS_CAGW_MAPPING | | (Optional) Wavelength subnets mapping (e.g. {{wavelength_zone_id}}:{{wavelength_zone_cidr}},{{wavelength_zone_id}}:{{wavelength_zone_cidr}})
