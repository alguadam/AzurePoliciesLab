$rgName = "{resourceGroupName}"
$storageAccountARMTemplate = "Templates\StorageAccount\deploy.json"
$uncompliantStorageAccountARMTemplateParameters = "Parameters\lab02-storageAccount.HTTP.json"
$compliantStorageAccountARMTemplateParameters = "Parameters\lab02-storageAccount.HTTPS.json"

# Deploy Uncompliant Storage Account (HTTP traffic allowed)
$httpStorageAccountAzDeploymentParams = @{
    ResourceGroupName     = $rgName
    TemplateFile          = $storageAccountARMTemplate
    TemplateParameterFile = $uncompliantStorageAccountARMTemplateParameters
    Name                  = "storageAccount-" + (Get-Date -Format FileDateTimeUniversal)
    ErrorAction           = "SilentlyContinue"
    ErrorVariable         = "saDeploymentError"
}
Write-Output "Deploying HTTP Storage Account"
New-AzResourceGroupDeployment @httpStorageAccountAzDeploymentParams | Out-Null
if ($saDeploymentError) {
    Write-Output "Error during Storage Account deployment"
    $saDeploymentError.Exception
}

# Deploy Compliant Storage Account (HTTP traffic disallowed)
$httpsStorageAccounttAzDeploymentParams = @{
    ResourceGroupName     = $rgName
    TemplateFile          = $storageAccountARMTemplate
    TemplateParameterFile = $compliantStorageAccountARMTemplateParameters
    Name                  = "storageAccount-" + (Get-Date -Format FileDateTimeUniversal)
}
Write-Output "Deploying HTTPS Storage Account"
New-AzResourceGroupDeployment @httpsStorageAccounttAzDeploymentParams | Out-Null