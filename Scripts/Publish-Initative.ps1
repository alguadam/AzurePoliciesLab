# Deploy a Policy Definition via ARM Template
$pathToARMTemplate = "Templates\StorageAccount\initiative.json"

$initiativeAzDeploymentParams = @{
    TemplateFile = $pathToARMTemplate
    Name         = "initiative-" + (Get-Date -Format FileDateTimeUniversal)
    Location     = "westeurope"
}

New-AzDeployment @initiativeAzDeploymentParams