# EKS Cluster Provisioning
This project simplifies the deployment of an EKS cluster, including a VPC and associated security groups.

## Steps to Deploy
Run the following commands:
```bash
# Initialize Terraform providers and modules
terraform init

# Validate the Terraform configuration files
terraform validate

# Preview the changes Terraform will make (dry-run)
terraform plan -out out.plan

# Apply the plan to create or update infrastructure
terraform apply out.plan

# Optionally, output the plan in JSON format for review
terraform show -json out.plan | jq > out.json
```