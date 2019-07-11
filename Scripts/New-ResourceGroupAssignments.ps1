# Deploy Assignments via ARM Template
# Assign to Resource Group for Tests
$rgName = "{resourceGroupName}"
$pathToARMTemplate = "Templates\Assignments\resourceGroup.json"
$pathToARMTemplateParameters = "Parameters\lab02-rgAssignments.json"

$assignmentAzDeploymentParams = @{
    ResourceGroupName     = $rgName
    TemplateFile          = $pathToARMTemplate
    TemplateParameterFile = $pathToARMTemplateParameters
    Name                  = "policyAssingments-" + (Get-Date -Format FileDateTimeUniversal)
}
New-AzResourceGroupDeployment @assignmentAzDeploymentParams