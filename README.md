# tf-aws-infra

🚀 Terraform and AWS Infrastructure Guide 📚
This guide provides Terraform commands to manage infrastructure on Amazon Web Services (AWS).

🛠️ Essential Terraform Commands
Use these commands to manage AWS infrastructure efficiently.

1️⃣ Initialize Terraform Directory
bash
```
terraform init
```

2️⃣ Generate and Review Execution Plan
bash
```
terraform plan
```

3️⃣ Apply Terraform Configuration
bash
```
terraform apply -var-file="example.tfvars" -auto-approve
```

4️⃣ Destroy AWS Infrastructure
bash
```
terraform destroy -var-file="example.tfvars" -auto-approve
```

Required ```.tfvar``` Variables 📝
For the Terraform scripts to work, ensure you have a ```.tfvar``` file.

Create your own ```tfvars``` file.

## SSL Certificate for demo Environment


### Importing the Certificate into AWS Certificate Manager (ACM)
The certificate was imported into ACM using the following command:

```bash
aws acm import-certificate \
  --certificate fileb://file_name.crt \
  --private-key fileb://demo.domainname.me.key \
  --certificate-chain fileb://filename.ca-bundle \
  --region us-east-1 \
  --profile demo