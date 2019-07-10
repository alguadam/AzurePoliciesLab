

 #Get-AzureRmSubscription | %{az policy state list --subscription $_.Id}

#Log to Azure Subscription
Login-AzureRmAccount

$Policies = [System.Collections.ArrayList]::new();

Get-AzureRmSubscription | %{
    
    $SubPolicyAsJson = az policy state list --subscription $_.Id

                                                                                                    
    $SubPolicy = $SubPolicyAsJson | ConvertFrom-Json;
    $null = $Policies.Add($SubPolicy);
    #$null = $Subscription.Add($SubPolicy);

    $result = @{ Policystates = $Policies};
    $result | ConvertTo-Json -Depth 15;

}

 $result | ConvertTo-Json -Depth 15 > policies.json 