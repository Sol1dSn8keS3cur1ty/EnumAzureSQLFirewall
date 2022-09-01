$Verbose = $True
function Write-Info ($Message) {
    If ($Verbose) {
        Write-Host $Message
    }
}
Write-Info "Building subscription(s) object."
$AADSubscriptions = Get-AzSubscription
$TotalCount = $AADSubscriptions.Count
If ($TotalCount -gt 1) {
    Write-Info "Done building subscription object, processing ${TotalCount} subscription"
} else {
    Write-Info "Done building subscriptions object, processing ${TotalCount} subscriptions"
}
$Progress = 0
$AADSubscriptions | ForEach-Object {
    $Subscription = $_
    $DisplayName = $Subscription.Name
    $Progress += 1
	If ([Int]$TotalCount -eq 0) {
		Write-Info "0 SQL Servers in $[DisplayName}"
    } else {
        $ProgressPercentage = (($Progress / $TotalCount) * 100) -As [Int]
        	If ($Progress -eq $TotalCount) {
            	Write-Info "Processing subscriptions: [${Progress}/${TotalCount}][${ProgressPercentage}%] Current subscription: ${DisplayName}"
        	} else {
            	If (($Progress % 100) -eq 0) {
                	Write-Info "Processing subscriptions: [${Progress}/${TotalCount}][${ProgressPercentage}%] Current subscription: ${DisplayName}"
				} 
			}
}

    $Current = [PSCustomObject]@{
        Name            = $Subscription.Name
        SubscriptionId  = $Subscription.SubscriptionId
        TenantId        = $Subscription.TenantId
    }
	$SubDisplayName = $_.Name
	Select-AzSubscription -SubscriptionID $_.Id | Out-Null
	Write-Info "Building SQL Server object for subscription ${SubDisplayName}"
	$AzSQLServers = Get-AzSQLServer
	$TotalCount = $AzSQLServers.Count
	If ($TotalCount -gt 1) {
		Write-Info "Done building SQL Server object, processing ${TotalCount} SQL servers"
	} else {
		Write-Info "Done building SQL Server object, processing ${TotalCount} SQL servers"
	}
	$Progress = 0   
	$AzSQLServers | ForEach-Object {    
		$SQL_S = $_
		$DisplayName = $SQL_S.ServerName
		$Progress += 1
		If ([Int]$TotalCount -eq 0) {
			Write-Info "*************** Warning *************** TotalCount equals 0"
       	} else {
			$ProgressPercentage = (($Progress / $TotalCount) * 100) -As [Int]
			If ($Progress -eq $TotalCount) {
				Write-Info "Processing SQL servers: [${Progress}/${TotalCount}][${ProgressPercentage}%] Current SQL Server: ${DisplayName}"
			} else {
				If (($Progress % 100) -eq 0) {
					Write-Info "Processing SQL servers: [${Progress}/${TotalCount}][${ProgressPercentage}%] Current SQL Server: ${DisplayName}"
				} 
			}
			}
			
	$RGName = $SQL_S.ResourceGroupName
	$AzSQLS = [PSCustomObject]@{
	AzSQLServerName = $SQL_S.ServerName
	ResourceGroupName = $RGName
	}
			
	ForEach ($S in $AzSQLS) {            
		$S_Rules = Get-AzSqlServerFirewallRule –ServerName $AzSQLS.AzSQLServerName -ResourceGroupName $AzSQLS.ResourceGroupName | Out-File -Filepath $($AzSQLS.AzSQLServerName + ".-FirewallRules.txt")			
            }
    }
}
Write-Info "Finished Enumerating SQL Server Firewall Rules!"
