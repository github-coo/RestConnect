﻿function Connect-ServiceClientSecret {
    <#
	.SYNOPSIS
		Connects using a client secret.
	
	.DESCRIPTION
		Connects using a client secret.
	
	.PARAMETER Resource
		The resource to authenticate to.

	.PARAMETER ClientID
		The ID of the registered app used with this authentication request.
	
	.PARAMETER TenantID
		The ID of the tenant connected to with this authentication request.
	
	.PARAMETER ClientSecret
		The actual secret used for authenticating the request.
	
	.EXAMPLE
		PS C:\> Connect-ServiceClientSecret -Resource $token.Resource -ClientID '<ClientID>' -TenantID '<TenantID>' -ClientSecret $secret
	
		Connects to the specified tenant using the specified client and secret.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
		[string]
		$Resource,

		[Parameter(Mandatory = $true)]
        [string]
        $ClientID,
		
        [Parameter(Mandatory = $true)]
        [string]
        $TenantID,
		
        [Parameter(Mandatory = $true)]
        [securestring]
        $ClientSecret
    )
	
    process {
		$body = @{
            resource      = $Resource
            client_id     = $ClientID
            client_secret = [PSCredential]::new('NoMatter', $ClientSecret).GetNetworkCredential().Password
            grant_type    = 'client_credentials'
        }
        try { $authResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" -Body $body -ErrorAction Stop }
        catch { throw }
		
        [pscustomobject]@{
            AccessToken = $authResponse.access_token
            ValidAfter  = (Get-Date -Date '1970-01-01').AddSeconds($authResponse.not_before).ToLocalTime()
            ValidUntil  = (Get-Date -Date '1970-01-01').AddSeconds($authResponse.expires_on).ToLocalTime()
            Scopes      = @()
        }
    }
}