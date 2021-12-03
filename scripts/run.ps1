param (
    [Parameter(Mandatory=$false)][String]$ResourceGroupName,
    [Parameter(Mandatory=$false)][String]$ServicePrincipalName,
    [Parameter(Mandatory=$false)][String]$ServicePrincipalPass,
    [Parameter(Mandatory=$false)][String]$SubscriptionId,
    [Parameter(Mandatory=$false)][String]$TenantId,
    [Parameter(Mandatory=$false)][String]$SourceControlType = "VsoGit"
)


#Connecting to Azure
Write-Verbose -Message "Checking and Installing Azure Powershell Module"
if (-not(Get-Module -Name Az.Accounts -ListAvailable)){
    Write-Warning "Module 'Az.Accounts' is missing or out of date. Installing module now."
    Install-Module -Name Az.Accounts, Az.Resources, Az.Automation -Scope CurrentUser -Force -AllowClobber
}

Write-Verbose -Message "Connecting to Azure"
$ServicePrincipalPassword = ConvertTo-SecureString -AsPlainText -Force -String $ServicePrincipalPass
$azureAppCred = New-Object System.Management.Automation.PSCredential ($ServicePrincipalName,$ServicePrincipalPassword)
Connect-AzAccount -ServicePrincipal -Credential $azureAppCred -Tenant $tenantId -Subscription $SubscriptionId



#Deploying the Azure Runbooks
$Runbooks = (Get-ChildItem -Path "./src").Name
$AutomationAccountName = (Get-AzResource -ResourceGroupName $ResourceGroupName | Where-Object ResourceType -eq "Microsoft.Automation/automationAccounts").name
$AutomationSourceControl = Get-AzAutomationSourceControl -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

#If the runbook exists in Azure, then just run a sync on it
try {
    Start-AzAutomationSourceControlSyncJob -SourceControlName $AutomationSourceControl.Name -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName
}
catch {
    Write-Error -Message "$($_)"
}