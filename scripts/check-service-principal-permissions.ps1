# Check and upgrade service principal permissions
# Run this if you want to enable automatic provider registration

# First, check current role assignments
Write-Host "Current role assignments for the service principal:"
az role assignment list --assignee "d7770754-c617-48a2-b2b7-5395f5ef0a19" --output table

# To grant Contributor access at subscription level (if needed):
# IMPORTANT: Only run this if you want the service principal to have broad permissions
# az role assignment create --assignee "d7770754-c617-48a2-b2b7-5395f5ef0a19" --role "Contributor" --scope "/subscriptions/0da47d90-b02b-48b0-9f3e-edfecde0384a"

# Or create a custom role with just provider registration permissions:
$customRoleDefinition = @"
{
  "Name": "Provider Registration",
  "Description": "Can register Azure resource providers",
  "Actions": [
    "*/register/action"
  ],
  "NotActions": [],
  "AssignableScopes": [
    "/subscriptions/0da47d90-b02b-48b0-9f3e-edfecde0384a"
  ]
}
"@

# Save and create the custom role
$customRoleDefinition | Out-File -FilePath "provider-registration-role.json"
# az role definition create --role-definition "provider-registration-role.json"
# az role assignment create --assignee "d7770754-c617-48a2-b2b7-5395f5ef0a19" --role "Provider Registration" --scope "/subscriptions/0da47d90-b02b-48b0-9f3e-edfecde0384a"

Write-Host "Review the commands above before executing them."