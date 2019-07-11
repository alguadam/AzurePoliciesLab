# Activity 2: Develop and Test your custom Policy

- [Activity 2: Develop and Test your custom Policy](#Activity-2-Develop-and-Test-your-custom-Policy)
  - [Introduction](#Introduction)
  - [Instructions](#Instructions)
    - [Task 1 - Develop your custom policy rule in an ARM Template](#Task-1---Develop-your-custom-policy-rule-in-an-ARM-Template)
    - [Task 2 - Develop your custom initiative in an ARM Template](#Task-2---Develop-your-custom-initiative-in-an-ARM-Template)
    - [Task 3 - Assign and test your Policy](#Task-3---Assign-and-test-your-Policy)
  - [Theoretical Content](#Theoretical-Content)
    - [Custom Policies Intro](#Custom-Policies-Intro)
    - [Azure Policy Definitions](#Azure-Policy-Definitions)
      - [Mode](#Mode)
      - [Display name and description](#Display-name-and-description)
      - [Parameters](#Parameters)
      - [Policy Rule](#Policy-Rule)
      - [Logical Operators](#Logical-Operators)
      - [Conditions, Fields and Values](#Conditions-Fields-and-Values)
      - [Aliases](#Aliases)
      - [Functions](#Functions)
      - [Effect](#Effect)
    - [Azure Policy Initiatives](#Azure-Policy-Initiatives)

## Introduction

In this activity you will learn how to create custom policies and custom initiatives so that you can gain control of Azure given your specific needs

## Instructions

### Task 1 - Develop your custom policy rule in an ARM Template

> Related theoretical content:
> + [Custom Policies intro](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%202%20(30%20min)%3A%20Develop%20and%20Test%20your%20custom%20Policy&pageId=309&wikiVersion=GBwikiMaster&anchor=custom-policies-intro)
> + [Azure Policy Definitions](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%202%20(30%20min)%3A%20Develop%20and%20Test%20your%20custom%20Policy&pageId=309&wikiVersion=GBwikiMaster&anchor=azure-policy-definitions)

In this Task, you will create a custom policy in an ARM Template that will deny deploying Storage Accounts allowing HTTP traffic

**Step 1 - Create the ARM Template for the Policy Definition in your Azure DevOps / Github Repo**

The policy will be defined in an ARM Template with the schema for [subscription deployments](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates#template-format) 

You can use the following template:

Suggested File Path: `Templates\StorageAccount\policy-denyHttp.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "functions": [],
    "resources": [],
    "outputs": {}
}
```
 
**Step 2 - Create the policy definition that will deny deploying Storage Accounts allowing HTTP traffic**

Policy definitions can be configured via [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/templates/) using the Resource Provider [`Microsoft.Authorization`](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/allversions) and the resource type [`policyDefinitions`](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2018-05-01/policydefinitions)

You can use the following template:

Suggested File Path: `Templates\StorageAccount\policy-denyHttp.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "functions": [],
    "resources": [
        {
            "name": "{The Policy Rule Definition name}",
            "type": "Microsoft.Authorization/policyDefinitions",
            "apiVersion": "2018-05-01",
            "properties": {
                "displayName": "{The Policy Rule Definition Display Name}",
                "description": "{The Policy Rule Definition description}",
                "mode": "All",
                "policyType": "Custom",
                "parameters": {},
                "policyRule": {
                    "if": {
                    },
                    "then": {
                    }
                }
            }
        }
    ],
    "outputs": {}
}
```

 You can take a look to the **properties of the Storage Account** in the Resource Provider [`microsoft.storage`](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/allversions) and the resource type [`storageaccounts`](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/2019-04-01/storageaccounts)

For the [`if` **condition**](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%202%20(30%20min)%3A%20Develop%20and%20Test%20your%20custom%20Policy&pageId=309&wikiVersion=GBwikiMaster&anchor=conditions%2C-fields-and-values), you will have to use [**aliases**](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%202%20(60%20min)%3A%20Develop%20and%20Test%20your%20custom%20Policy&pageId=309&wikiVersion=GBwikiMaster&anchor=aliases). You can use the [`Get-AzPolicyAlias -NamespaceMatch Microsoft.Storage`](https://docs.microsoft.com/en-us/powershell/module/az.resources/get-azpolicyalias?view=azps-2.2.0&viewFallbackFrom=azps-1.0.0) cmdlet to find out Storage Account available aliases

The [`then` **effect**](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%202%20(30%20min)%3A%20Develop%20and%20Test%20your%20custom%20Policy&pageId=309&wikiVersion=GBwikiMaster&anchor=effect) must deny the deployment.

**Step 3 - Publish your policy definition**

Once you have a rule ready to be tested, we will test it by directly publishing it to our Azure Subscription.

There are not many mechanisms today that let us test the policy locally, so this is the approach we will take for this Activity.

You can publish your Policy to your subscription by using the following PowerShell Script:

```PowerShell
# Deploy a Policy Definition via ARM Template
$pathToARMTemplate = "Templates\StorageAccount\policy-denyHttp.json"

$policyDefinitionAzDeploymentParams = @{
    TemplateFile = $pathToARMTemplate
    Name         = "policyDeployment-" + (Get-Date -Format FileDateTimeUniversal)
    Location     = "westeurope"
}
New-AzDeployment @policyDefinitionAzDeploymentParams
```

If you have successfully published your policy definition, you should be able to see it in your subscription:

> Azure Portal > All Services > Policy > Definitions > Definition type = Policy, Type = Custom

![Published Policy](/.attachments/lab02-exercise01-step03-publishedPolicy.png)

You can also find the policy via PowerShell:

```PowerShell
Get-AzPolicyDefinition | ? {$_.properties.policyType -eq "Custom"}
```

----

### Task 2 - Develop your custom initiative in an ARM Template

> Related theoretical content:
> + [Azure Policy Initiatives](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%202%20(30%20min)%3A%20Develop%20and%20Test%20your%20custom%20Policy&pageId=309&wikiVersion=GBwikiMaster&anchor=azure-policy-initiatives)

In this Task, you will create a custom initiative in an ARM Template that will contain the policy definition created in the Task 1

**Step 1 - Create the ARM Template for the Initiative in your Azure DevOps / Github Repo**

As in Task 1, the initiative will be defined in an ARM Template with the schema for [subscription deployments](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates#template-format).

You can use the following template:

Suggested File Path: `Templates\StorageAccount\initiative.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "functions": [],
    "resources": [],
    "outputs": {}
}
```

**Step 2 - Create an Initiative that contains the policy defined in Task 1**

Initiatives can be configured via [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/templates/) using the Resource Provider [`Microsoft.Authorization`](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/allversions) and the resource type [`policySetDefinitions`](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2018-05-01/policysetdefinitions)

You can use the following template:

Suggested File Path: `Templates\StorageAccount\initiative.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {
        "policyName-storageAccountDenyHttps": "StorageAccount-DenyHTTP"
    },
    "functions": [],
    "resources": [
        {
            "name": "{The Initiative name}",
            "type": "Microsoft.Authorization/policySetDefinitions",
            "apiVersion": "2018-05-01",
            "properties": {
                "displayName": "{The Initiative display name}",
                "description": "{The Initiative description}",
                "policyDefinitions": [
                    {
                        "policyDefinitionId": "[resourceId('Microsoft.Authorization/policyDefinitions',variables('{The Policy Rule Definition name from Task 1}'))]"
                    }
                ]
            }
        }
    ],
    "outputs": {}
}
```

**Step 3 - Publish your initiative**

Once you have your template ready, we will again test it by directly publishing it to our Azure Subscription.

You can publish your Initiative to your subscription by using the following PowerShell Script:

```PowerShell
# Deploy a Policy Definition via ARM Template
$pathToARMTemplate = "Templates\StorageAccount\initiative.json"

$initiativeAzDeploymentParams = @{
    TemplateFile = $pathToARMTemplate
    Name         = "initiative-" + (Get-Date -Format FileDateTimeUniversal)
    Location     = "westeurope"
}

New-AzDeployment @initiativeAzDeploymentParams
```

If you have successfully published your initiative, you should be able to see it in your subscription:

> Azure Portal > All Services > Policy > Definitions > Definition type = Initiative, Type = Custom

![Published Policy](/.attachments/lab02-exercise02-step03-publishedInitiative.png)

You can also find the initiative via PowerShell:

```PowerShell
Get-AzPolicySetDefinition | ? {$_.properties.policyType -eq "Custom"}
```

----

### Task 3 - Assign and test your Policy

In this Task, you will test if your policy is working as expected by assigning the policy to a Resource Group and deploying au uncompliant resource so that the policy denies the deployment

**Step 1 - Create the ARM Template for the Assignment in your Azure DevOps / Github Repo**

This time, the assignment will be defined in an ARM Template with the schema for [resource group deployments](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates#template-format).

You can use the following ARM Template:

Suggested File Path: `Templates\Assignments\resourceGroup.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "builtInPolicyDefinitions": {
            "type": "array",
            "defaultValue": []
        },
        "customPolicyDefinitions": {
            "type": "array",
            "defaultValue": []
        },
        "builtInInitiatives": {
            "type": "array",
            "defaultValue": []
        },
        "customInitiatives": {
            "type": "array",
            "defaultValue": []
        },
        "resourceGroupName": {
            "type": "string",
            "defaultValue": "[resourceGroup().name]"
        },
        "resourceGroupSubscriptionId": {
            "type": "string",
            "defaultValue": "[subscription().subscriptionId]"
        }
    },
    "variables": {
        "subscriptionResourceId": "[concat('/subscriptions/',parameters('resourceGroupSubscriptionId'))]",
        "resourceGroupResourceId": "[concat('/subscriptions/',parameters('resourceGroupSubscriptionId'),'/resourceGroups/',parameters('resourceGroupName'))]",
        "copy": [
            {
                "name": "builtInPolicyDefinitionResourceIds",
                "count": "[if(empty(parameters('builtInPolicyDefinitions')),1,length(parameters('builtInPolicyDefinitions')))]",
                "input": {
                    "resourceId": "[if(empty(parameters('builtInPolicyDefinitions')),'dummy',concat('/providers/Microsoft.Authorization/policyDefinitions/',parameters('builtInPolicyDefinitions')[copyIndex('builtInPolicyDefinitionResourceIds')].policyDefinitionName))]",
                    "name": "[if(empty(parameters('builtInPolicyDefinitions')),'dummy',parameters('builtInPolicyDefinitions')[copyIndex('builtInPolicyDefinitionResourceIds')].policyDefinitionName)]",
                    "parameters": "[if(empty(parameters('builtInPolicyDefinitions')),'dummy',parameters('builtInPolicyDefinitions')[copyIndex('builtInPolicyDefinitionResourceIds')].parameters)]",
                    "displayName": "[if(empty(parameters('builtInPolicyDefinitions')),'dummy',parameters('builtInPolicyDefinitions')[copyIndex('builtInPolicyDefinitionResourceIds')].assignmentDisplayName)]",
                    "identity": "[if(empty(parameters('builtInPolicyDefinitions')),'dummy',parameters('builtInPolicyDefinitions')[copyIndex('builtInPolicyDefinitionResourceIds')].managedIdentity)]"
                }
            },
            {
                "name": "customPolicyDefinitionResourceIds",
                "count": "[if(empty(parameters('customPolicyDefinitions')),1,length(parameters('customPolicyDefinitions')))]",
                "input": {
                    "resourceId": "[if(empty(parameters('customPolicyDefinitions')),'dummy',concat(variables('subscriptionResourceId'),'/providers/Microsoft.Authorization/policyDefinitions/',parameters('customPolicyDefinitions')[copyIndex('customPolicyDefinitionResourceIds')].policyDefinitionName))]",
                    "name": "[if(empty(parameters('customPolicyDefinitions')),'dummy',parameters('customPolicyDefinitions')[copyIndex('customPolicyDefinitionResourceIds')].policyDefinitionName)]",
                    "parameters": "[if(empty(parameters('customPolicyDefinitions')),'dummy',parameters('customPolicyDefinitions')[copyIndex('customPolicyDefinitionResourceIds')].parameters)]",
                    "displayName": "[if(empty(parameters('customPolicyDefinitions')),'dummy',parameters('customPolicyDefinitions')[copyIndex('customPolicyDefinitionResourceIds')].assignmentDisplayName)]",
                    "identity": "[if(empty(parameters('customPolicyDefinitions')),'dummy',parameters('customPolicyDefinitions')[copyIndex('customPolicyDefinitionResourceIds')].managedIdentity)]"
                }
            },
            {
                "name": "builtInInitiativeResourceIds",
                "count": "[if(empty(parameters('builtInInitiatives')),1,length(parameters('builtInInitiatives')))]",
                "input": {
                    "resourceId": "[if(empty(parameters('builtInInitiatives')),'dummy',concat('/providers/Microsoft.Authorization/policySetDefinitions/',parameters('builtInInitiatives')[copyIndex('builtInInitiativeResourceIds')].initiativeName))]",
                    "name": "[if(empty(parameters('builtInInitiatives')),'dummy',parameters('builtInInitiatives')[copyIndex('builtInInitiativeResourceIds')].initiativeName)]",
                    "parameters": "[if(empty(parameters('builtInInitiatives')),'dummy',parameters('builtInInitiatives')[copyIndex('builtInInitiativeResourceIds')].parameters)]",
                    "displayName": "[if(empty(parameters('builtInInitiatives')),'dummy',parameters('builtInInitiatives')[copyIndex('builtInInitiativeResourceIds')].assignmentDisplayName)]",
                    "identity": "[if(empty(parameters('builtInInitiatives')),'dummy',parameters('builtInInitiatives')[copyIndex('builtInInitiativeResourceIds')].managedIdentity)]"
                }
            },
            {
                "name": "customInitiativeResourceIds",
                "count": "[if(empty(parameters('customInitiatives')),1,length(parameters('customInitiatives')))]",
                "input": {
                    "resourceId": "[if(empty(parameters('customInitiatives')),'dummy',concat(variables('subscriptionResourceId'),'/providers/Microsoft.Authorization/policySetDefinitions/',parameters('customInitiatives')[copyIndex('customInitiativeResourceIds')].initiativeName))]",
                    "name": "[if(empty(parameters('customInitiatives')),'dummy',parameters('customInitiatives')[copyIndex('customInitiativeResourceIds')].initiativeName)]",
                    "parameters": "[if(empty(parameters('customInitiatives')),'dummy',parameters('customInitiatives')[copyIndex('customInitiativeResourceIds')].parameters)]",
                    "displayName": "[if(empty(parameters('customInitiatives')),'dummy',parameters('customInitiatives')[copyIndex('customInitiativeResourceIds')].assignmentDisplayName)]",
                    "identity": "[if(empty(parameters('customInitiatives')),'dummy',parameters('customInitiatives')[copyIndex('customInitiativeResourceIds')].managedIdentity)]"
                }
            }
        ],
        "managedIdentity": {
            "type": "SystemAssigned"
        },
        "policyResourceIds": "[concat(if(empty(parameters('builtInPolicyDefinitions')),parameters('builtInPolicyDefinitions'),variables('builtInPolicyDefinitionResourceIds')),if(empty(parameters('customPolicyDefinitions')),parameters('customPolicyDefinitions'),variables('customPolicyDefinitionResourceIds')),if(empty(parameters('builtInInitiatives')),parameters('builtInInitiatives'),variables('builtInInitiativeResourceIds')),if(empty(parameters('customInitiatives')),parameters('customInitiatives'),variables('customInitiativeResourceIds')))]"
    },
    "functions": [],
    "resources": [
        {
            "condition": "[not(empty(variables('policyResourceIds')))]",
            "copy": {
                "name": "policyAssignmentCopy",
                "count": "[if(empty(variables('policyResourceIds')),1,length(variables('policyResourceIds')))]"
            },
            "type": "Microsoft.Authorization/policyAssignments",
            "apiVersion": "2018-05-01",
            "name": "[if(empty(variables('policyResourceIds')),'dummy',variables('policyResourceIds')[copyIndex('policyAssignmentCopy')].name)]",
            "location": "[resourceGroup().location]",
            "properties": {
                "policyDefinitionId": "[variables('policyResourceIds')[copyIndex('policyAssignmentCopy')].resourceId]",
                "scope": "[variables('resourceGroupResourceId')]",
                "parameters": "[variables('policyResourceIds')[copyIndex('policyAssignmentCopy')].parameters]",
                "displayName": "[variables('policyResourceIds')[copyIndex('policyAssignmentCopy')].displayName]"
            },
            "Identity": "[if(variables('policyResourceIds')[copyIndex('policyAssignmentCopy')].identity,variables('managedIdentity'),json('null'))]"
        }
    ],
    "outputs": {}
}
```

**Step 2 - Create the Parameters File for the Assignment in your Azure DevOps / Github Repo**

The template from step 1 will allow you to configure a Parameters file that will assign one or more policies and one or more definitions to one Resource Group.

You need to create your Parameters Path in your Azure DevOps / Github Repo:

Suggested File Path: `Parameters\lab02-rgAssignments.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "customPolicyDefinitions": {
            "value": [
                {
                    "policyDefinitionName": "{the name given to the Initiative from Task 2}",
                    "parameters": {},
                    "assignmentDisplayName": "{the display name to be shown}",
                    "managedIdentity": false
                }
            ]
        }
    }
}
```

**Step 3 - Deploy your assignments**

Once you have your template and parameters ready, we will deploy the ARM Template so that the assignments get configured.

You can publish your Assignments by using the following PowerShell Script:

```PowerShell
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
```

If you have successfully published your assignments, you should be able to see it in your Resource Group:

> Azure Portal > All Services > Resource Groups > {your Resource Group} > Policies > Assignments > = Initiative, Type = Custom

![Published Assignment](/.attachments/lab02-exercise03-step03-publishedAssignment.png)

You can also find the assignment via PowerShell:

```PowerShell
$rgName = "{resourceGroupName}"
$rgResourceId = (Get-AzResourceGroup -Name $rgName).ResourceId

Get-AzPolicyAssignment -Scope $rgResourceId
```

----

**Step 4 - Test your Storage Account deployment**

Now you have all in place to test if the policy will deny deployments of Storage Accounts with HTTP traffic enabled.

We will deploy a Storage Account resource to see if the policy is working as expected.

Use the following ARM Template for this purpose:

Suggested File Path: `Templates\StorageAccount\deploy.json`
```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountName": {
            "type": "string"
        },
        "supportsHttpsTrafficOnly": {
            "type": "bool"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2018-07-01",
            "name": "[parameters('storageAccountName')]",
            "location": "West Europe",
            "dependsOn": [],
            "sku": {
                "name": "Standard_RAGRS"
            },
            "kind": "StorageV2",
            "properties": {
                "accessTier": "Hot",
                "supportsHttpsTrafficOnly": "[parameters('supportsHttpsTrafficOnly')]"
            }
        }
    ],
    "outputs": {}
}
```
Now, configure to different Parameter files: one parameter file will deploy a compliant Storage Account, and the other parameter file will deploy an uncompliant Storage Account


Suggested File Path: `Parameters\lab02-storageAccount.HTTP.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountName": {
            "value": "{your-storage-account-name}"
        },
        "supportsHttpsTrafficOnly": {
            "value": false
        }
    }
}
```

Suggested File Path: `Parameters\lab02-storageAccount.HTTPS.json`
```json

{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountName": {
            "value": "{your-storage-account-name}"
        },
        "supportsHttpsTrafficOnly": {
            "value": true
        }
    }
}
```

Deploy the Storage Accounts by using the following Script:

```PowerShell
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
```

If your policy is well configured, you should receive an error message when trying to deploy your uncompliant Storage Account, something like:

```
0:56:50 - Error: Code=InvalidTemplateDeployment; Message=The template deployment failed because of policy violation. Please see details for more information.

0:56:50 - Error: Code=RequestDisallowedByPolicy; Message=Resource '{your-storage-account-name}' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"StorageAccount-DenyHTTP","id":"/subscriptions/{your-subscription-id}/resourcegroups/{your-resource-group-name}/providers/Microsoft.Authorization/policyAssignments/StorageAccount-DenyHTTP"},"policyDefinition":{"name":"Storage Account - Deny HTTP traffic","id":"/subscriptions/{your-subscription-id}/providers/Microsoft.Authorization/policyDefinitions/StorageAccount-DenyHTTP"}},{"policyAssignment":{"name":"StorageAccountInitiative","id":"/subscriptions/{your-subscription-id}/resourcegroups/{your-resource-group-name}/providers/Microsoft.Authorization/policyAssignments/StorageAccountInitiative"},"policyDefinition":{"name":"Storage Account - Deny HTTP traffic","id":"/subscriptions/{your-subscription-id}/providers/Microsoft.Authorization/policyDefinitions/StorageAccount-DenyHTTP"},"policySetDefinition":{"name":"Initiative for Storage Accounts","id":"/subscriptions/{your-subscription-id}/providers/Microsoft.Authorization/policySetDefinitions/StorageAccountInitiative"}}]'.
```

However, when deploying the compliant Storage Account, the policy should allow the deployment to go on

----
 
## Theoretical Content

### Custom Policies Intro

A [custom policy](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-custom-policy-definition) definition will allow you to define your own rules for using Azure. These rules often enforce:
+ Security practices
+ Cost management
+ Organization-specific rules (like naming or locations)

Whatever the business driver for creating a custom policy, the steps are the same for defining the new custom policy.

### Azure Policy Definitions 

> Read more about Azure Policy Definition structure in [this article](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure).

Each [Azure Policy definition](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure) describes resource compliance and what effect to take when a resource is non-compliant.

You use JSON to create a policy definition. The schema used by Azure Policy can be found in [https://schema.management.azure.com/schemas/2018-05-01/policyDefinition.json](https://schema.management.azure.com/schemas/2018-05-01/policyDefinition.json), and it will allow you to define for each Policy Definition:

```json
{
    "name": "PolicyName",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "mode": "all | indexed",
        "parameters": { },
        "displayName": "",
        "description": "",
        "policyRule": {
            "if": {
                <condition> | <logical operator>
            },
            "then": {
                "effect": "deny | audit | append | auditIfNotExists | deployIfNotExists | disabled"
            }
        }
    }
}
```

#### Mode

> Read more about modes in [this article](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#mode)

The **mode** determines which resource types will be evaluated for a policy. The supported modes are:

+ `all`: evaluate resource groups and all resource types
+ `indexed`: only evaluate resource types that support tags and location

We recommend that you set mode to `all` in most cases.

`indexed` should be used when creating policies that enforce tags or locations. The exception is resource groups.  Policies that enforce location or tags on a resource group should set mode to `all` and specifically target the `Microsoft.Resources/subscriptions/resourceGroups` type.

#### Display name and description

> Read more about display name and description in [this article](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#display-name-and-description)

You use displayName and description to identify the policy definition and provide context for when it's used. `displayName` has a maximum length of 128 characters and `description` a maximum length of 512 characters.

E.g.

```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": { },
        "policyRule": { }
    }
}
```

#### Parameters

> Read more about parameters [this article](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameter-properties) 

Parameters help simplify your policy management by reducing the number of policy definitions. By including parameters in a policy definition, you can reuse that policy for different scenarios by using different values.

The following structure contains the required properties for defining parameters. See all the available properties in this [link](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameter-properties).

E.g.

```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": {
            "tagName": {
                "type": "string",
                "metadata": {
                    "description": "The name of the tag that will determine the Security Level applied to the Resource Group",
                    "displayName": "Security Level Tag Name"
                },
                "defaultValue": [
                    "SecurityLevel"
                ]
            }
        },
        "policyRule": {}
    }
}
```

In the policy rule, you reference parameters with the following parameters deployment value function syntax:

```json
{
    "field": "location",
    "in": "[parameters('allowedLocations')]"
}
```

#### Policy Rule

> Read more about policy rules in [this article](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#policy-rule)

The policy rule consists of If and Then blocks. In the If block, you define one or more conditions that specify when the policy is enforced. You can apply logical operators to these conditions to precisely define the scenario for a policy.

In the Then block, you define the effect that happens when the If conditions are fulfilled.

```json
{
    "if": {
        <condition> | <logical operator>
    },
    "then": {
        "effect": "deny | audit | append | auditIfNotExists | deployIfNotExists | disabled"
    }
}
```

E.g.

```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": {
            "tagName": {
                "type": "string",
                "metadata": {
                    "description": "The name of the tag that will determine the Security Level applied to the Resource Group",
                    "displayName": "Security Level Tag Name"
                },
                "defaultValue": [
                    "SecurityLevel"
                ]
            }
        },
        "policyRule": {
            "if": {
                <condition> | <logical operator>
            },
            "then": {
                "effect": ""
            }
        }
    }
}
```

#### Logical Operators

Supported logical operators are:

+ `"not": {condition or operator}`
+ `"allOf": [{condition or operator},{condition or operator}]`
+ `"anyOf": [{condition or operator},{condition or operator}]`

The not syntax inverts the result of the condition. The allOf syntax (similar to the logical And operation) requires all conditions to be true. The anyOf syntax (similar to the logical Or operation) requires one or more conditions to be true. You can nest logical operators.

E.g.

```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": {
            "tagName": {
                "type": "string",
                "metadata": {
                    "description": "The name of the tag that will determine the Security Level applied to the Resource Group",
                    "displayName": "Security Level Tag Name"
                },
                "defaultValue": [
                    "SecurityLevel"
                ]
            }
        },
        "policyRule": {
            "if": {
                "allOf": [
                    {condition or another operator}
                ]
            },
            "then": {
                "effect": ""
            }
        }
    }
}
```

#### Conditions, Fields and Values

A **condition** evaluates whether a field or the value accessor meets certain criteria. Take a look to the supported conditions in this [link](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#conditions).

Conditions are formed by using **fields**. A field matches properties in the resource request payload and describes the state of the resource.  Take a look to the supported conditions in this [link](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#fields).

```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": {
            "tagName": {
                "type": "string",
                "metadata": {
                    "description": "The name of the tag that will determine the Security Level applied to the Resource Group",
                    "displayName": "Security Level Tag Name"
                },
                "defaultValue": [
                    "SecurityLevel"
                ]
            }
        },
        "policyRule": {
            "if": {
                "allOf": [
                    {
                        "field": "type",
                        "equals": "Microsoft.Storage/storageAccounts"
                    }
                ]
            },
            "then": {
                "effect": ""
            }
        }
    }
}
```

Conditions can also be formed using `value`. `value` checks conditions against [parameters](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameters), [supported template functions](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#policy-functions), or literals. `value` is paired with any supported condition.

E.g.
```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": {
            "tagName": {
                "type": "string",
                "metadata": {
                    "description": "The name of the tag that will determine the Security Level applied to the Resource Group",
                    "displayName": "Security Level Tag Name"
                },
                "defaultValue": [
                    "SecurityLevel"
                ]
            }
        },
        "policyRule": {
            "if": {
                "allOf": [
                    {
                        "field": "type",
                        "equals": "Microsoft.Storage/storageAccounts"
                    },
                    {
                        "value": "[concat('tags[', parameters('tagName'), ']')]",
                        "in": [
                            "Advanced",
                            "Basic"
                        ]
                    }
                ]
            },
            "then": {
                "effect": ""
            }
        }
    }
}
```

#### Aliases

> Read more about aliases in the following [link](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#aliases)

Aliases can be used as fields. Property aliases allow you to access specific properties for a resource type. Aliases enable you to restrict what values or conditions are allowed for a property on a resource. Each alias maps to paths in different API versions for a given resource type. During policy evaluation, the policy engine gets the property path for that API version.

E.g.
```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": {
            "tagName": {
                "type": "string",
                "metadata": {
                    "description": "The name of the tag that will determine the Security Level applied to the Resource Group",
                    "displayName": "Security Level Tag Name"
                },
                "defaultValue": [
                    "SecurityLevel"
                ]
            }
        },
        "policyRule": {
            "if": {
                "allOf": [
                    {
                        "field": "type",
                        "equals": "Microsoft.Storage/storageAccounts"
                    },
                    {
                        "value": "[concat('tags[', parameters('tagName'), ']')]",
                        "in": [
                            "Advanced",
                            "Basic"
                        ]
                    },
                    {
                        "anyOf": [
                            {
                                "field": "Microsoft.Storage/storageAccounts/NetworkAcls",
                                "exists": "false"
                            },
                            {
                                "field": "Microsoft.Storage/storageAccounts/NetworkAcls.defaultAction",
                                "equals": "Allow"
                            }
                        ]
                    }
                ]
            },
            "then": {
                "effect": ""
            }
        }
    }
}
```

The list of aliases is always growing. To find what aliases are currently supported by Azure Policy, use one of the following methods:
+ [PowerShell](https://docs.microsoft.com/en-us/powershell/module/az.resources/get-azpolicyalias): `Get-AzPolicyAlias`
+ [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/provider?view=azure-cli-latest): `az provider list --query [*].namespace`, [`az provider show --namespace Microsoft.Automation --expand "resourceTypes/aliases" --query "resourceTypes[].aliases[].name"`
+ [REST API](https://docs.microsoft.com/en-us/rest/api/resources/providers): `GET https://management.azure.com/providers/?api-version=2017-08-01&$expand=resourceTypes/aliases`

> Find more information about the `[*]` alias in [this link](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#understanding-the--alias)

#### Functions

All [Resource Manager template functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions) are available to use within a policy rule, except the following functions and user-defined functions:

+ copyIndex()
+ deployment()
+ list*
+ newGuid()
+ pickZones()
+ providers()
+ reference()
+ resourceId()
+ variables()

Additionally, the field function is available to policy rules. field is primarily used with `AuditIfNotExists` and DeployIfNotExists to reference fields on the resource that are being evaluated

#### Effect

Each policy definition in Azure Policy has a single effect. That effect determines what happens when the policy rule is evaluated to match. The effects behave differently if they are for a new resource, an updated resource, or an existing resource.

Requests to create or update a resource through Azure Resource Manager are evaluated by Azure Policy first. You can read about the order of evaluation that Azure Policy follows in this [link](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#order-of-evaluation).

Azure Policy supports the following types of effect:
+ `deny`: generates an event in the activity log and fails the request
+ `audit`: generates a warning event in activity log but doesn't fail the request
+ `append`: adds the defined set of fields to the request
+ `auditIfNotExists`: enables auditing if a resource doesn't exist
+ `deployIfNotExists`: deploys a resource if it doesn't already exist
+ `disabled`: doesn't evaluate resources for compliance to the policy rule

For complete details on each effect, order of evaluation, properties, and examples, see [Understanding Azure Policy Effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects).

E.g.
```json
{
    "name": "StorageAccountAuditFirewallEnabled",
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "displayName": "Audit that firewall is enabled in Storage Accounts",
        "mode": "All",
        "policyType": "Custom",
        "description": "Audit that firewall is enabled in Storage Accounts",
        "parameters": {
            "tagName": {
                "type": "string",
                "metadata": {
                    "description": "The name of the tag that will determine the Security Level applied to the Resource Group",
                    "displayName": "Security Level Tag Name"
                },
                "defaultValue": [
                    "SecurityLevel"
                ]
            }
        },
        "policyRule": {
            "if": {
                "allOf": [
                    {
                        "field": "type",
                        "equals": "Microsoft.Storage/storageAccounts"
                    },
                    {
                        "value": "[concat('tags[', parameters('tagName'), ']')]",
                        "in": [
                            "Advanced",
                            "Basic"
                        ]
                    },
                    {
                        "anyOf": [
                            {
                                "field": "Microsoft.Storage/storageAccounts/NetworkAcls",
                                "exists": "false"
                            },
                            {
                                "field": "Microsoft.Storage/storageAccounts/NetworkAcls.defaultAction",
                                "equals": "Allow"
                            }
                        ]
                    }
                ]
            },
            "then": {
                "effect": "deny"
            }
        }
    }
}
```

### Azure Policy Initiatives

> Read more about Azure Policy Initiatives [here](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#initiatives)

[Initiatives](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#initiatives) enable you to group several related policy definitions to simplify assignments and management because you work with a group as a single item.

Initiatives can be configured via [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/templates/) using the Resource Provider [`Microsoft.Authorization`](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/allversions) and the resource type [`policySetDefinitions`](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2018-05-01/policysetdefinitions)

E.g. of initiative definition:

```json
{
    "name": "StorageAccountInitiative",
    "type": "Microsoft.Authorization/policySetDefinitions",
    "apiVersion": "2018-05-01",
    "properties": {
        "policyType": "Custom",
        "displayName": "Initiative for Storage Accounts",
        "description": "Initiative for policies related to Storage Accounts",
        "policyDefinitions": [
            {
                "policyDefinitionId": "[resourceId('Microsoft.Authorization/policyDefinitions','policyDefinitionName01')]",
                "policyDefinitionId": "[resourceId('Microsoft.Authorization/policyDefinitions','policyDefinitionName02')]"
            }
        ]
    }
}
```