# Activity 1: Deploy built-in Azure Policies via IaC, CI and CD

- [Activity 1: Deploy built-in Azure Policies via IaC, CI and CD](#Activity-1-Deploy-built-in-Azure-Policies-via-IaC-CI-and-CD)
  - [Introduction](#Introduction)
  - [Instructions](#Instructions)
    - [Task 1 - Create assignments for your built-in policies in your Azure DevOps / Github Repo](#Task-1---Create-assignments-for-your-built-in-policies-in-your-Azure-DevOps--Github-Repo)
    - [Task 2 - Create the a Build pipeline (.yaml) for your files](#Task-2---Create-the-a-Build-pipeline-yaml-for-your-files)
    - [Task 3 - Deploy the assignments via Release pipeline](#Task-3---Deploy-the-assignments-via-Release-pipeline)
  - [Theoretical Content](#Theoretical-Content)
    - [Azure Policy Service](#Azure-Policy-Service)
    - [Built-in Policies](#Built-in-Policies)
    - [Built-in Initiatives](#Built-in-Initiatives)
    - [Assignments](#Assignments)

## Introduction

In this activity you will configure Build and Release pipelines so that you can manage assignment of built-in policies and initiatives using Infrastructure as Code.

## Instructions

### Task 1 - Create assignments for your built-in policies in your Azure DevOps / Github Repo 

> Related theoretical content:
> + [Azure Policy Service](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%201%20(15%20min)%3A%20Deploy%20built%252Din%20Azure%20Policies%20via%20IaC%2C%20CI%20and%20CD&pageId=308&wikiVersion=GBwikiMaster&anchor=azure-policy-service#azure-policy-service)
> + [Built-in Policies](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%201%20(15%20min)%3A%20Deploy%20built%252Din%20Azure%20Policies%20via%20IaC%2C%20CI%20and%20CD&pageId=308&wikiVersion=GBwikiMaster&anchor=azure-policy-service#built-in-policies)
> + [Built-in Initiatives](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%201%20(15%20min)%3A%20Deploy%20built%252Din%20Azure%20Policies%20via%20IaC%2C%20CI%20and%20CD&pageId=308&wikiVersion=GBwikiMaster&anchor=azure-policy-service#built-in-initiatives)
> + [Assignments](https://dev.azure.com/alguadamorg/Azure%20Policies%20Lab/_wiki/wikis/Azure-Policies-Activity.wiki?pagePath=%2FAzure%20Policies%20Lab%2FLab%201%20(15%20min)%3A%20Deploy%20built%252Din%20Azure%20Policies%20via%20IaC%2C%20CI%20and%20CD&pageId=308&wikiVersion=GBwikiMaster&anchor=azure-policy-service#assignments)

In this Task, you will define assignments of one or more built-in policies and initiatives to a existing Resource Group.

**Step 1 - Create the ARM Template for the Assignment in your Azure DevOps / Github Repo**

You will create an ARM Template that will allow you to define assignments for [resource group deployments](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates#template-format).

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

**Step 2 - Create the parameters File for the Assignment in your Azure DevOps / Github Repo**

You define a ARM Parameters file where you will configure define assignments for your Resource Group.

In this step, you will configure one assignment for a built-in policy.

You can use the following file as a template:

Suggested File Path: `Parameters\lab01-rgAssignments.json`
```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "builtInPolicyDefinitions": {
            "value": [
                {
                    "policyDefinitionName": "{builtin-policy-definition-name}",
                    "parameters": {
                        "{parameterName}": {
                            "value": "{parameterValue}"
                        },
                        "{parameterName}": {
                            "value": "{parameterValue}"
                        }
                    },
                    "assignmentDisplayName": "Key Vault Diagnostics",
                    "managedIdentity": false
                }
            ]
        },
        "resourceGroupName": {
            "value": "{your-resource-group-name}"
        }
    }
}
```

where: 

+ The `{builtin-policy-definition-name}` value must be the name assigned to the built-in policy that you want to use.
+ The `{parameterName}` must be the name of the parameter that you want to configure for the policy definition. If there are no parameters needed, leave the value for `parameters` as an empty object (`"parameters" : {}`)
+ The `{your-resource-group-name}` value must be the name of the Resource Group where you will assign the policy

You can check the available Policy Definitions in the Azure Portal or programmatically (PowerShell, Azure CLI, etc).

> Azure Portal > All Services > Policy > Definitions > Definition type = Policy, Type = Buit-in

![Built-in Policy](/.attachments/lab01-theoreticalcontent-builtinpolicy-portal.png)

You can also find the available policies via PowerShell:

```PowerShell
Get-AzPolicyDefinition | ? {$_.properties.policyType -eq "Builtin"}
```

----

### Task 2 - Create the a Build pipeline (.yaml) for your files 

In this Task, you will configure a Build pipeline that will let you version and use your templates and parameter files in the release pipeline.

We will use two different build pipelines because normally, parameters have a different lifecycle than ARM Templates, and ARM Templates are designed to be reused for different scenarios, so we will want to version those artifacts differently.

**Step 1 - Create the build pipeline for your assignments ARM Template**

In this step, you will create a build pipeline that will publish your ARM Template as an artifact.

You can use the following .yaml file:

Suggested File Path: `ci\assignments.yaml`

```yaml
name: $(Build.DefinitionName)-$(SourceBranchName)-$(Date:yyyyMMdd).$(Rev:rr)

variables:
  RepoName: {your-repo-name}
  FolderPath: Templates/Assignments #change it you didn't follow our suggested path
  ArtifactName: assignments

resources:
  repositories:
    - repository: main
      type: git
      name: '$(RepoName)'

trigger: #continuous integration will be enabled for all branches and the path containing the ARM template
  branches:
    include:
      - '*'
  paths:
    include:
      - Templates/Assignments #change it you didn't follow our suggested path

jobs:
- job: Build
  displayName: Build
  pool:
    vmImage: ubuntu-16.04
  workspace:
    clean: all
  
  steps:
  - task: PublishBuildArtifacts@1
    displayName: 'Publish Template Files as Azure DevOps artifact'
    inputs:
      PathtoPublish: $(FolderPath)
      ArtifactName: $(ArtifactName)
```

Now, configure the YAML file above as a Build Pipeline and run it

> Pipeline > Builds > New > New build pipeline > Azure Repos Git (YAML) / Github (YAML) > {Your Repo} > Existing Azure Pipelines YAML file > Branch : {your branch}, Path : {ci\assignments.yaml}

We suggest that you rename the build pipeline as `ci-assignments`

![Create Release Pipeline](/.attachments/lab01-exercise02-step01-assignmentsBuildPipeline.png)

**Step 2 - Create the build pipeline for your Parameters file**

In this step, you will create a build pipeline that will publish your parameters file as an artifact.

You can use the following .yaml file:

Suggested File Path: `ci\parameters.yaml`

```yaml
name: $(Build.DefinitionName)-$(SourceBranchName)-$(Date:yyyyMMdd).$(Rev:rr)

variables:
  RepoName: {your-repo-name}
  FolderPath: Parameters #change it you didn't follow our suggested path
  ArtifactName: parameters

resources:
  repositories:
    - repository: main
      type: git
      name: '$(RepoName)'

trigger: #continuous integration will be enabled for all branches and the path containing the parameter files
  branches:
    include:
      - '*'
  paths:
    include:
      - Parameters #change it you didn't follow our suggested path

stages:
- stage: build
  jobs:
  - job: Build
    displayName: Build
    pool:
      vmImage: ubuntu-16.04
    workspace:
      clean: all
    
    steps:
    - task: PublishBuildArtifacts@1
      displayName: 'Publish Template Files as Azure DevOps artifact'
      inputs:
        PathtoPublish: $(FolderPath)
        ArtifactName: $(ArtifactName)
```

Now, configure the YAML file above as a Build Pipeline and run it

> Pipeline > Builds > New > New build pipeline > Azure Repos Git (YAML) / Github (YAML) > {Your Repo} > Existing Azure Pipelines YAML file > Branch : {your branch}, Path : {ci\parameters.yaml}

We suggest that you rename the build pipeline as `ci-parameters`

![Create Release Pipeline](/.attachments/lab01-exercise02-step02-parametersBuildPipeline.png)

----

### Task 3 - Deploy the assignments via Release pipeline

In this Task, you will configure an Azure DevOps release pipeline that will deploy your assignments. Once this pipeline is configured, you will manage your assignments by just modifying your parameters file.

**Step 1 - Configure and deploy your release pipeline**

Now that your build pipelines run, we have both the ARM Template and the parameters file to be used as Azure DevOps artifacts.

Create a new Azure DevOps release pipeline with the name `cd-assignments`

> Pipelines > Releases > New > New release pipeline

![Create Release Pipeline](/.attachments/lab01-exercise03-step01-newReleasePipeline.png)

Add the artifacts from the Build Pipelines

> Artifacts | + Add > Source type: Build, Project: {your project name}, Source (build pipeline): ci-assignments > Add

![Add Templates Artifacts](/.attachments/lab01-exercise03-step01-addTemplatesArtifact.png)

> Artifacts | + Add > Source type: Build, Project: {your project name}, Source (build pipeline): ci-parameters > Add

![Add Parameters Artifacts](/.attachments/lab01-exercise03-step01-addParametersArtifact.png)

Create a stage with the name `Policy Assignments`

> Stages | + Add > Empty job > Stage name: Policy Assignments

![Create Stage](/.attachments/lab01-exercise03-step01-createStage.png)

Add a [Resource Group Deployment](https://aka.ms/argtaskreadme) task to your `Policy Assignments` stage

> Tasks > Agent job + > Search : Resource Group Deployment > Add

![Add Resource Group Deployment Task](/.attachments/lab01-exercise03-step01-addResourceGroupDeploymentTask.png)
 
Configure the following properties in the task:

| property name       | property value                                                                               |
| ------------------- | -------------------------------------------------------------------------------------------- |
| Display name        | Deploy assignments                                                                           |
| Azure Subscription  | {your connection endpoint with permissions on your azure subscription}                       |
| Action              | Create or update resource group                                                              |
| Resource group      | {your resource group for testing}                                                            |
| Location            | {if you didn't create the resource group, this will be the location for your resource group} |
| Template location   | Linked artifact                                                                              |
| Template            | `$(System.DefaultWorkingDirectory)/_ci-assignments/assignments/resourceGroup.json`           |
| Template parameters | `$(System.DefaultWorkingDirectory)/_ci-parameters/parameters/lab01-rgAssignments.json`       |
| Deployment mode     | Incremental                                                                                  |

![Resource Group Deployment Task Configuration](/.attachments/lab01-exercise03-step01-configureDeploymentTask.png)

Save and run your Release Pipeline

> Create release > Create

Troubleshoot if the deployment didn't succeed

**Step 2 - Enable continuous deployment for your Release and add a new assignment**

Now you can enable Continuous Deployment for your Release Pipeline so that every time you change your parameters file, the new assignments are automatically deployed.

To do this, edit your Release Definition and enable continuos integration in your `_ci-parameters` artifact

> Artifact `_ci-parameters`: Continuous deployment trigger > Enabled

![Enable continuous deployment](/.attachments/lab01-exercise03-step02-enableContinuousDeployment.png)

Next, edit your parameter files to add some more built-in initiatives and/or policy definitions.

E.g. of parameters file:
```
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "builtInPolicyDefinitions": {
            "value": [
                {
                    "policyDefinitionName": "cf820ca0-f99e-4f3e-84fb-66e913812d21",
                    "parameters": {
                        "effect": {
                            "value": "AuditIfNotExists"
                        },
                        "requiredRetentionDays": {
                            "value": "360"
                        }
                    },
                    "assignmentDisplayName": "Key Vault Diagnostics",
                    "managedIdentity": false
                },
                {
                    "policyDefinitionName": "3657f5a0-770e-44a3-b44e-9431ba1e9735",
                    "parameters": {},
                    "assignmentDisplayName": "Automation account variables should be encrypted;",
                    "managedIdentity": false
                }
            ]
        },
        "builtInInitiatives": {
            "value": [
                {
                    "initiativeName": "c96b2a9c-6fab-4ac2-ae21-502143491cd4",
                    "parameters": {},
                    "assignmentDisplayName": "Audit Windows VMs with a pending reboot",
                    "managedIdentity": true
                }
            ]
        }
    }
}
```

Commit and push your changes. This should trigger the continuous integration trigger configured in the build pipeline (yaml) and the continuous deployment trigger in your release pipeline

If the deployment goes as expected, you should be able to see the following assignments in your Resource Group:

![Resource Group Assignments](/.attachments/lab01-exercise03-step02-resourceGroupAssignments.png)

----

## Theoretical Content

### Azure Policy Service

[Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview) is a service in Azure that you use to create, assign, and manage policies. These policies enforce different rules and effects over your resources, so those resources stay compliant with your corporate standards and service level agreements. Azure Policy meets this need by evaluating your resources for non-compliance with assigned policies. For example, you can have a policy to allow only a certain SKU size of virtual machines in your environment. Once this policy is implemented, new and existing resources are evaluated for compliance. With the right type of policy, existing resources can be brought into compliance.

### Built-in Policies

A [policy definition](https://docs.microsoft.com/en-us/azure/governance/policy/overview#policy-definition) contains conditions under which it's enforced. And, it has a defined effect that takes place if the conditions are met.

E.g. of built-in policy:

```json
{
  "properties": {
    "id": "/providers/Microsoft.Authorization/policyDefinitions/cf820ca0-f99e-4f3e-84fb-66e913812d21",
    "type": "Microsoft.Authorization/policyDefinitions",
    "name": "cf820ca0-f99e-4f3e-84fb-66e913812d21",
    "displayName": "Diagnostic logs in Key Vault should be enabled",
    "policyType": "BuiltIn",
    "mode": "Indexed",
    "description": "Audit enabling of diagnostic logs. This enables you to recreate activity trails to use for investigation purposes; when a security incident occurs or when your network is compromised",
    "metadata": {
      "category": "Key Vault"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ],
        "defaultValue": "AuditIfNotExists"
      },
      "requiredRetentionDays": {
        "type": "String",
        "metadata": {
          "displayName": "Required retention (days)",
          "description": "The required diagnostic logs retention in days"
        },
        "defaultValue": "365"
      }
    },
    "policyRule": {
      "if": {
        "field": "type",
        "equals": "Microsoft.KeyVault/vaults"
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Insights/diagnosticSettings",
          "existenceCondition": {
            "anyOf": [
              {
                "allOf": [
                  {
                    "field": "Microsoft.Insights/diagnosticSettings/logs[*].retentionPolicy.enabled",
                    "equals": "true"
                  },
                  {
                    "field": "Microsoft.Insights/diagnosticSettings/logs[*].retentionPolicy.days",
                    "equals": "[parameters('requiredRetentionDays')]"
                  },
                  {
                    "field": "Microsoft.Insights/diagnosticSettings/logs.enabled",
                    "equals": "true"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "not": {
                      "field": "Microsoft.Insights/diagnosticSettings/logs[*].retentionPolicy.enabled",
                      "equals": "true"
                    }
                  },
                  {
                    "field": "Microsoft.Insights/diagnosticSettings/logs.enabled",
                    "equals": "true"
                  }
                ]
              }
            ]
          }
        }
      }
    }
  }
}
```

The Policy definition above will audit enabling of diagnostic logs for Key Vaults.

In Azure Policy, there are several built-in policies that are available by default. You can check the available Policy Definitions in the Azure Portal or programmatically (PowerShell, Azure CLI, etc).

> Azure Portal > All Services > Policy > Definitions > Definition type = Policy, Type = Buit-in

![Built-in Policy](/.attachments/lab01-theoreticalcontent-builtinpolicy-portal.png)

You can also find the available policies via PowerShell:

```PowerShell
Get-AzPolicyDefinition | ? {$_.properties.policyType -eq "Builtin"}
```

To implement these policy definitions (both built-in and custom definitions), you'll need to assign them to a specific scope. [Policy evaluation](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#order-of-evaluation) happens with several different actions, such as policy assignment or policy updates.

### Built-in Initiatives

An [initiative definition](https://docs.microsoft.com/en-us/azure/governance/policy/overview#initiative-definition) is a collection of policy definitions that are tailored towards achieving a singular overarching goal. Initiative definitions simplify managing and assigning policy definitions. They simplify by grouping a set of policies as one single item.

E.g. of built-in initiative

```json
{
  "Name": "06122b01-688c-42a8-af2e-fa97dd39aa3b",
  "ResourceId": "/providers/Microsoft.Authorization/policySetDefinitions/06122b01-688c-42a8-af2e-fa97dd39aa3b",
  "ResourceName": "06122b01-688c-42a8-af2e-fa97dd39aa3b",
  "ResourceType": "Microsoft.Authorization/policySetDefinitions",
  "Properties": {
    "displayName": "Audit Windows VMs in which the Administrators group does not contain only the specified members",
    "policyType": "BuiltIn",
    "description": "This initiative deploys the policy requirements and audits Windows virtual machines in which the Administrators group does not contain only the specified members. For more information on Guest Configuration policies, please visit https://aka.ms/gcpol",
    "metadata": {
      "category": "Guest Configuration"
    },
    "parameters": {
      "Members": {
        "type": "String",
        "metadata": {
          "displayName": "Members",
          "description": "A semicolon-separated list of all the expected members of the Administrators local group. Ex: Administrator; myUser1; myUser2"
        }
      }
    },
    "policyDefinitions": [
      {
        "policyDefinitionReferenceId": "Deploy_AdministratorsGroupMembers",
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/b821191b-3a12-44bc-9c38-212138a29ff3",
        "parameters": {
          "Members": {
            "value": "[parameters('Members')]"
          }
        }
      },
      {
        "policyDefinitionReferenceId": "Audit_AdministratorsGroupMembers",
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/cc7cda28-f867-4311-8497-a526129a8d19"
      }
    ]
  },
  "PolicySetDefinitionId": "/providers/Microsoft.Authorization/policySetDefinitions/06122b01-688c-42a8-af2e-fa97dd39aa3b"
}
```

In Azure Policy, there are several built-in initiatives that are available by default. You can check the available Initiatives in the Azure Portal or programmatically (PowerShell, Azure CLI, etc).

> Azure Portal > All Services > Policy > Definitions > Definition type = Initiatives, Type = Buit-in

![Built-in Policy](/.attachments/lab01-theoreticalcontent-builtininitiatives-portal.png)

You can also find the available initiatives via PowerShell:

```PowerShell
Get-AzPolicySetDefinition | ? {$_.properties.policyType -eq "Builtin"}
```

### Assignments

A [policy assignment](https://docs.microsoft.com/en-us/azure/governance/policy/overview#policy-assignment) is a policy definition that has been assigned to take place within a specific scope. This scope could range from a [management group](https://docs.microsoft.com/en-us/azure/governance/management-groups/overview) to a resource group. The term scope refers to all the resource groups, subscriptions, or management groups that the policy definition is assigned to. Policy assignments are inherited by all child resources. This design means that a policy applied to a resource group is also applied to resources in that resource group. However, you can exclude a subscope from the policy assignment.

Like a policy assignment, an [initiative assignment](https://docs.microsoft.com/en-us/azure/governance/policy/overview#initiative-assignment) is an initiative definition assigned to a specific scope. Initiative assignments reduce the need to make several initiative definitions for each scope. This scope could also range from a management group to a resource group.