# Java Azure Container Apps Demo# Java Azure Demo Project



This repository demonstrates how to build, containerize, and deploy a Java Spring Boot application to **Azure Container Apps** using **Terraform** for infrastructure-as-code, **Azure Container Registry** for container image management, and **GitHub Actions** for CI/CD.This repository demonstrates how to build, provision, and deploy a simple Java application to **Microsoft Azure App Service** using **Terraform** for infrastructure-as-code and **GitHub Actions** for CI/CD.



## 🎯 What This Project Demonstrates---



- **Azure Container Apps**: Modern, serverless container hosting## 🧱 Project Structure

- **Azure Container Registry (ACR)**: Private container image storage

- **Infrastructure as Code**: Complete infrastructure management with Terraform```

- **CI/CD Pipeline**: Automated build, test, and deployment with GitHub Actionsjava-azure-demo/

- **Containerization**: Docker-based application packaging├── src/

- **Health Monitoring**: Spring Boot Actuator integration├── target/

├── infra/

---│   ├── main.tf

│   ├── variables.tf

## 🏗️ Architecture│   ├── outputs.tf

├── scripts/

```│   ├── create-resource-group.ps1

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐│   ├── create-service-principal.ps1

│   GitHub Repo   │───▶│  GitHub Actions │───▶│ Azure Container ││   ├── create-tf-backend.ps1

│                 │    │                 │    │     Registry    │├── .github/

└─────────────────┘    └─────────────────┘    └─────────────────┘│   └── workflows/

                                 │                       ││       └── deploy.yml

                                 ▼                       ▼└── pom.xml

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐```

│   Terraform     │───▶│ Azure Resource  │◀───│ Azure Container │

│ Infrastructure  │    │     Group       │    │      Apps       │---

└─────────────────┘    └─────────────────┘    └─────────────────┘

                                 │                       │## ⚙️ Prerequisites

                                 ▼                       ▼

                       ┌─────────────────┐    ┌─────────────────┐* Azure CLI

                       │ Log Analytics   │    │   Your Java     │* Terraform

                       │   Workspace     │    │   Application   │* Java 17+

                       └─────────────────┘    └─────────────────┘* Maven

```* GitHub account connected to Azure Subscription



------



## 🧱 Project Structure## 🚀 Setup Guide



```### Create Resource Group

java-azure-demo/

├── src/main/java/com/example/demo/```powershell

│   └── DemoApplication.java          # Spring Boot application./scripts/create-resource-group.ps1 -resourceGroup "java-azure-demo-rg" -location "eastus"

├── src/main/resources/```

│   └── application.properties        # App configuration

├── infra/                           # Terraform infrastructure### Create Terraform Backend

│   ├── main.tf                      # Main infrastructure definition

│   ├── variables.tf                 # Input variables```powershell

│   └── outputs.tf                   # Output values./scripts/create-tf-backend.ps1

├── scripts/                         # Setup scripts```

│   ├── create-resource-group.ps1

│   ├── create-service-principal.ps1Use the generated backend config in `infra/main.tf`.  Set access key:

│   ├── create-tf-backend.ps1

│   └── check-service-principal-permissions.ps1```powershell

├── .github/workflows/$env:ARM_ACCESS_KEY = "<your-key>"

│   └── deploy.yml                   # CI/CD pipeline```

├── Dockerfile                       # Container definition

├── pom.xml                         # Maven configuration### Create Service Principal

└── README.md

``````powershell

./scripts/create-service-principal.ps1 -spName "java-azure-deployer" -resourceGroup "java-azure-demo-rg"

---```



## ⚙️ PrerequisitesStore the JSON output in your GitHub Secret as `AZURE_CREDENTIALS`.



- **Azure CLI** (v2.x+)---

- **Terraform** (v1.0+)

- **Java 17+** (Eclipse Temurin recommended)## 🧠 Troubleshooting Terraform Authentication

- **Maven** (v3.6+)

- **Docker** (for local testing)If you get `az login` errors, define provider auth explicitly using Service Principal JSON, mark it as sensitive, and pass via GitHub Secrets.

- **GitHub account** with Azure subscription access

- **PowerShell** (for setup scripts)### Local Testing



---```powershell

cd infra

## 🚀 Quick Startterraform init

terraform plan -var="azure_credentials=$(Get-Content ../azure_credentials.json -Raw)"

### 1. Clone and Setup```



```bashNever commit your local credentials file. Add it to `.gitignore`.

git clone https://github.com/mctrinity/java-azure-demo.git

cd java-azure-demo---

```

## 🧹 Cleanup

### 2. Create Azure Resources

To remove everything created by Terraform:

```powershell

# Create resource group```powershell

./scripts/create-resource-group.ps1 -resourceGroup "java-azure-demo-rg" -location "eastus"cd infra

terraform destroy -auto-approve

# Create Terraform backend storage```

./scripts/create-tf-backend.ps1

To remove backend storage:

# Create service principal for GitHub Actions

./scripts/create-service-principal.ps1 -spName "java-azure-deployer" -resourceGroup "java-azure-demo-rg"```powershell

```az group delete --name tfstate-rg --yes --no-wait

```

### 3. Configure GitHub Secrets

---

Add these secrets to your GitHub repository:

### 🧹 Managing GitHub Actions Logs Securely (PowerShell)

- **`AZURE_CREDENTIALS`**: Service principal JSON from step 2

- **`ARM_ACCESS_KEY`**: Terraform backend storage keySometimes early workflow runs may accidentally include sensitive information (like Azure credentials in logs). You can safely delete those old runs using the **GitHub CLI**.



### 4. Deploy#### 🧩 Step 1 — Check if GitHub CLI is Installed



```bash```powershell

git add .gh --version

git commit -m "Initial deployment"```

git push origin main

```If you see a version number, you’re good to go. If not, install it using **winget**:



The GitHub Actions workflow will automatically:```powershell

1. 🏗️ Create infrastructure with Terraformwinget install --id GitHub.cli

2. 📦 Build the Java application```

3. 🐳 Build and push Docker image to ACR

4. 🚀 Deploy to Azure Container AppsOr download manually from:

👉 [https://cli.github.com/](https://cli.github.com/)

---

#### 🔐 Step 2 — Authenticate GitHub CLI

## 🌐 Application Endpoints

```powershell

Once deployed, your application provides these endpoints:gh auth login

```

- **Main App**: `https://your-container-app-url/`

  - Returns: `"Hello from Java App deployed to Azure Container Apps!"`Follow prompts:

- **Health Check**: `https://your-container-app-url/actuator/health`

  - Spring Boot health status1. Choose **GitHub.com**

- **App Info**: `https://your-container-app-url/api/info`2. Choose **HTTPS**

  - Application metadata and runtime information3. Authenticate via **web browser**

4. Confirmation:

---

   ```

## 🏗️ Infrastructure Components   ✓ Logged in as <your-username>

   ```

### Azure Resources Created:

Check status:

1. **Resource Group**: `java-azure-demo-rg`

   - Container for all resources```powershell

gh auth status

2. **Azure Container Registry**: `javaazuredemoappacr````

   - Private Docker image storage

   - Basic SKU for cost optimization#### 🧹 Step 3 — Delete Old Workflow Runs



3. **Log Analytics Workspace**: `java-azure-demo-app-law`List recent runs:

   - Logging and monitoring for Container Apps

```powershell

4. **Container Apps Environment**: `java-azure-demo-app-env`gh run list --limit 10

   - Managed environment for Container Apps```



5. **Container App**: `java-azure-demo-app`Delete by ID:

   - Your Java application runtime

   - Auto-scaling: 0-2 replicas```powershell

   - External ingress on port 8080gh run delete <run-id> --confirm

```

### Cost Optimization Features:

Bulk-delete all runs for this workflow:

- **Scale to Zero**: App scales down to 0 replicas when not in use

- **Basic ACR**: Cost-effective registry tier```powershell

- **Shared Infrastructure**: Container Apps Environment shared across appsgh run list --workflow "Deploy Java App to Azure with Terraform" --limit 100 |

ForEach-Object { $_.Split(' ')[0] } |

---ForEach-Object { gh run delete $_ --confirm }

```

## 🔧 Local Development

> ⚠️ **Note:** This is permanent and cannot be undone.

### Build and Test Locally

```bash
# Build the application
mvn clean package

# Run locally
java -jar target/java-azure-demo-0.0.1-SNAPSHOT.jar

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/actuator/health
curl http://localhost:8080/api/info
```

### Build Docker Image Locally

```bash
# Build image
docker build -t java-azure-demo .

# Run container
docker run -p 8080:8080 java-azure-demo

# Test
curl http://localhost:8080/
```

---

## 🔍 Troubleshooting

### Common Issues and Solutions:

#### 1. **Provider Registration Errors**
```bash
# Register required Azure providers
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.OperationalInsights
```

#### 2. **Service Principal Permissions**
```powershell
# Check current permissions
./scripts/check-service-principal-permissions.ps1
```

#### 3. **Docker Build Failures**
- Ensure `target/*.jar` exists before building Docker image
- Check Dockerfile base image availability

#### 4. **Container App Not Accessible**
- Verify ingress is enabled and external
- Check Container Apps Environment and Log Analytics Workspace are created
- Review Container App logs in Azure Portal

### Debugging Commands:

```bash
# Check deployment status
az containerapp show --name java-azure-demo-app --resource-group java-azure-demo-rg

# View application logs
az containerapp logs show --name java-azure-demo-app --resource-group java-azure-demo-rg --follow

# Check ACR images
az acr repository list --name javaazuredemoappacr

# View Terraform state
cd infra && terraform show
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) performs:

### Infrastructure Phase:
1. **Authentication**: Login with service principal
2. **Provider Registration**: Ensure required Azure providers are available
3. **Terraform Init**: Initialize backend state
4. **Drift Detection**: Check for infrastructure changes
5. **Terraform Apply**: Create/update Azure resources

### Application Phase:
1. **Java Setup**: Configure JDK 17
2. **Build**: Compile and package with Maven
3. **Docker Build**: Create container image with application
4. **ACR Push**: Upload image to Azure Container Registry
5. **Deploy**: Update Container App with new image

### Quality Gates:
- Build must succeed before deployment
- Infrastructure must exist before app deployment
- Health checks verify successful deployment

---

## 🧹 Cleanup

### Remove Application and Infrastructure:

```bash
# Destroy infrastructure
cd infra
terraform destroy -auto-approve

# Remove Terraform backend (optional)
az group delete --name tfstate-rg --yes --no-wait
```

### Clean Up Container Images:

```bash
# Remove old images from ACR
az acr repository delete --name javaazuredemoappacr --repository java-azure-demo --yes
```

---

## 📊 Monitoring and Observability

### Built-in Monitoring:

- **Container Apps Metrics**: CPU, memory, request count in Azure Portal
- **Log Analytics**: Centralized logging and querying
- **Spring Boot Actuator**: Health checks and application metrics

### Accessing Logs:

```bash
# Real-time logs
az containerapp logs show --name java-azure-demo-app --resource-group java-azure-demo-rg --follow

# Query specific time range
az monitor log-analytics query \
  --workspace java-azure-demo-app-law \
  --analytics-query "ContainerAppConsoleLogs_CL | where TimeGenerated > ago(1h)"
```

---

## 🔒 Security Best Practices

### Implemented Security Features:

1. **Private Container Registry**: Images stored in private ACR
2. **Managed Identity**: Container Apps can use managed identity for Azure resources
3. **Network Security**: Container Apps Environment provides network isolation
4. **Secrets Management**: ACR credentials stored as Container App secrets
5. **Least Privilege**: Service principal has minimal required permissions

### Security Considerations:

- Regularly update base Docker images
- Scan container images for vulnerabilities
- Use Azure Key Vault for sensitive configuration
- Enable Azure Defender for containers
- Implement proper RBAC for resource access

---

## 📚 Additional Resources

- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [GitHub Actions for Azure](https://docs.microsoft.com/en-us/azure/developer/github/)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally and with CI/CD
5. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🎉 Success Story

This project successfully demonstrates a modern, cloud-native approach to Java application deployment:

- **From App Service to Container Apps**: Migrated due to quota limitations, resulting in better scalability
- **Proper CI/CD**: Automated pipeline from code to production
- **Infrastructure as Code**: Reproducible and version-controlled infrastructure
- **Container-First**: Modern application packaging and deployment
- **Cost Optimized**: Pay-per-use model with scale-to-zero capabilities

**Deployment Status**: ✅ **Successfully Running**

Visit your deployed application and see the magic in action! 🚀