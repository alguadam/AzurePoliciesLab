
## Introduction

The CCO Dashboard Policies extension allows you to validate if the policies and initiatives that you defined are compliant or not. 

![image](https://github.com/alguadam/AzurePoliciesLab/blob/master/Tools/img/MSReadyPoliciesLab.png?raw=true)

## Requirements

- The Continuous Optimization Power BI Dashboard Policies extension is a Power BI Template that requires to download and install the Microsoft Power BI Desktop Edition from the Microsoft Store. Below you can find the minimum requirements to run the Dashboard
    -	Windows 10 version **14393.0** or **higher**.
    -	Internet access from the computer running Microsoft Power BI desktop.
    - An Azure account on the desired tenant space with permissions on the subscriptions to read from the Azure Services described above.

## Instructions

### Setting up the Continuous Optimization Power BI Dashboard
#### Credentials
By default, the template doesn’t have any Azure Account credentials preloaded. Hence, the first step to start showing subscriptions data is to sign-in with the right user credentials.

#### Clean Credentials on the Data Source
In some cases, old credentials are cached by previous logins using Power BI Desktop and the dashboard might show errors or blank fields.

- Click on Data sources in **Current file/Global permissions**.
- Click on **Clear Permissions**.
- Click on **Clear All Permissions**.

#### Refresh the dashboard
If the permissions and credentials are properly flushed it should ask you for credentials for each REST API and you will have to set the Privacy Levels for each of them.

- Click on **Refresh**.
  
#### Credentials for <span>management.azure.com</span> REST API request:
- Click on **Organizational Account**.
- Click on **Sign in**.
- Click on **Connect**.


### Privacy Levels Configuration for All APIs
- On **Privacy levels…**.
- Select **Organizational**.
- Click on **Save**.


#### Enter Access Web content credentials

- Make sure that you select **Organization account** type.
- Click on **Sign in**.
  
