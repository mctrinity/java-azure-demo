# Fix deployment by re-creating infrastructure
# Navigate to infra directory
cd infra

# Initialize Terraform (you'll need to set ARM_ACCESS_KEY environment variable)
# $env:ARM_ACCESS_KEY = "your-terraform-backend-access-key"
# $env:TF_VAR_azure_credentials = '{"subscriptionId":"your-sub-id","clientId":"your-client-id","clientSecret":"your-client-secret","tenantId":"your-tenant-id"}'

# terraform init
# terraform plan -var='azure_credentials=$env:TF_VAR_azure_credentials'
# terraform apply -var='azure_credentials=$env:TF_VAR_azure_credentials'

Write-Host "Please set the required environment variables first:"
Write-Host "1. Set ARM_ACCESS_KEY for Terraform backend"
Write-Host "2. Set TF_VAR_azure_credentials with your service principal credentials"
Write-Host "3. Then run the terraform commands above"