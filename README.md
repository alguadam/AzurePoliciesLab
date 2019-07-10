# Welcome

Welcome to this lab

This lab will guide you through the creation and management of [Azure Policies](https://docs.microsoft.com/en-us/azure/governance/policy/overview) and [Assignments](https://docs.microsoft.com/en-us/azure/governance/policy/overview#policy-assignment) using Azure DevOps

# Lab prerequisites

## Theoretical prerequisites

The goal of this Lab is to put focus on how to create and deploy Azure Policies and assignments using ARM Templates, Azure DevOps Repos or Github and Azure DevOps Pipelines.

However, this Lab will not explain the required DevOps toolset, so in order to succeed with this lab you need to know how to work with:
+ ARM Templates
+ Azure Repos / Github
+ Azure Pipelines (Classic and YAML)


## Recommended software for your PC

### Azure PowerShell Az module

The [Azure Az PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az) will be needed. 

```Powershell
# Install Module Azure Az
Register-PSRepository -Default
Install-Module Az -Force
```

### IDE (Visual Studio Code)

You will need a IDE to let you work with an Azure DevOps or GitHub Repository and ARM Templates. We recommend that you use [Visual Studio Code](https://code.visualstudio.com/) for this lab with at least the following extensions installed:
+ [Azure Repos](https://marketplace.visualstudio.com/items?itemName=ms-vsts.team)
+ [Azure Resource Manager Tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)
+ [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)

## Pre-provisioned Environment

You can use a pre-provisioned environment for this lab in [Cloud Labs](https://aka.ms/R-AIST314).

This environment will provision for you:
+ An Azure DevOps Project
+ An Azure Subscription
+ An Azure Resource Group
+ An AAD User with Owner permissions assigned to the Resource Group and permissions to work with Policies at subscription level
+ An AAD Service Principal with Owner permissions assigned to the Resource Group and permissions to work with Policies at subscription level.

You will need to **add the provisioned Service Principal to the Azure DevOps project** as a [Azure RM Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#create-an-azure-resource-manager-service-connection-with-an-existing-service-principal).

Then you can use [Visual Studio Code to clone](https://code.visualstudio.com/docs/editor/versioncontrol#_cloning-a-repository) the Repo and start the lab or use your own GitHub repo.

## Configure your own environment

If you want to do this lab in your own environment istead of the Pre-provisioned environment, you need to configure the prerequisites listed below:

### Git Repo (Azure DevOps Repo / Github)

You will write and version your ARM Templates using a Git Repo. You have two options for 

+ Option 1 - [Azure DevOps Repos](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/?view=azure-devops): See how to get your free Azure DevOps Project [here](https://docs.microsoft.com/en-us/azure/devops/user-guide/sign-up-invite-teammates?view=azure-devops)
+ Option 2 - [GitHub](https://help.github.com/en/articles/create-a-repo) repos: see how to get your [Github account](https://github.com/join).

See how to [clone your Repo with Visual Studio Code](https://code.visualstudio.com/docs/editor/versioncontrol#_cloning-a-repository)

### Azure Pipelines

You will configure CD and CI using [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops). You will need an Azure DevOps Project [here](https://docs.microsoft.com/en-us/azure/devops/user-guide/sign-up-invite-teammates?view=azure-devops) in order to use Pipelines.

You can use both [Azure Repos](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/azure-repos-git?view=azure-devops) and [Github](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml) with your Pipelines

### Azure DevOps Service Connection (Azure Active Directory Service Principal)

You wil use a [Service Principal connected to your Azure DevOps pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints) that will allow you to deploy resources to Azure.

If you have your own Azure Subscription, you can [let Azure DevOps create one Service Principal for you](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#create-a-service-connection).

If you don't have access to your own subscription, you can use the following Service Principal:

```
Subscription ID : 67e1610d-40e5-4d22-9346-f860a28825d7
Application (client) ID : e1aae0bd-8491-4262-a237-5fddd2dbc7e2
Directory (tenant) ID : 72f988bf-86f1-41af-91ab-2d7cd011db47
Password : xlBI/mVq7MH8A7jQU3QTPb+ffbbLZS]-
```
### Azure Subscription and Permissions

Custom Policies and Initiatives are defined at Subscription level, so for this lab you will need to have access to one Azure Subscription.

If you don't have one, we will grant you access to our Azure Policies Lab subscription

In this subscription:

Your [Deployment Service Principal](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) needs to have at least the following [permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations):


| Action                                             | Description                                                               |
| -------------------------------------------------- | ------------------------------------------------------------------------- |
| */read                                             | Read resources of all types, except secrets                               |
| Microsoft.Authorization/policyassignments/*        | Create and manage policy assignments                                      |
| Microsoft.Authorization/policydefinitions/*        | Create and manage policy definitions                                      |
| Microsoft.Authorization/policysetdefinitions/*     | Create and manage policy sets                                             |
| Microsoft.PolicyInsights/*                         | Work with compliance information                                          |
| Microsoft.Resources/checkPolicyCompliance/*        | Check the compliance status of a given resource against resource policies |
| Microsoft.Resources/deployments/*                  | Manage Deployments at Subscription level                                  |
| Microsoft.Resources/subscriptions/resourcegroups/* | Manage Deployments at Resource Group level                                |
| Microsoft.KeyVault/*                               | Work with Key Vaults                                                      |
| Microsoft.Compute/*                                | Work with Virtual Machines                                                |
| Microsoft.Storage/*                                | Work with Storage Accounts                                                |
| Microsoft.Network/*                                | Work with Virtual Networks                                                |

Your user needs to have at least the following [permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations):

| Action                                             | Description                                                               |
| -------------------------------------------------- | ------------------------------------------------------------------------- |
| */read                                             | Read resources of all types, except secrets.                              |
| Microsoft.Authorization/policyassignments/*        | Create and manage policy assignments                                      |
| Microsoft.Authorization/policydefinitions/*        | Create and manage policy definitions                                      |
| Microsoft.Authorization/policysetdefinitions/*     | Create and manage policy sets                                             |
| Microsoft.PolicyInsights/*                         | Work with compliance information                                          |
| Microsoft.Resources/checkPolicyCompliance/*        | Check the compliance status of a given resource against resource policies |
| Microsoft.Resources/deployments/*                  | Manage Deployments at Subscription level                                  |
| Microsoft.Resources/subscriptions/resourcegroups/* | Manage Deployments at Resource Group level                                |
| Microsoft.Storage/*                                | Work with Storage Accounts                                                |

### Register the Azure Policy Insights resource provider

Register the Azure [Policy Insights](https://docs.microsoft.com/en-us/rest/api/policy-insights/) resource provider using Azure PowerShell to validate that your subscription works with the resource provider. To register a resource provider, you must have permission to run the register action operation for the resource provider. This operation is included in the Contributor and Owner roles. 

Run the following command to register the resource provider:

```PowerShell
Register-AzResourceProvider -ProviderNamespace 'Microsoft.PolicyInsights'
```
