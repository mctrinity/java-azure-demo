# Quick manual fix - create web app directly
az appservice plan create --name java-azure-demo-app-plan --resource-group java-azure-demo-rg --sku B1 --is-linux
az webapp create --name java-azure-demo-app --resource-group java-azure-demo-rg --plan java-azure-demo-app-plan --runtime "JAVA:17-java17"

# Then your deployment should work