
param (
    $EndPoint,
    $DatabaseId,
    $CollectionId,
    $DatabaseSigningKey,
    $Body,
    $DatabaseOrderID
)
    
    
# connection data
$ResourceType = "docs";
$ResourceLink = "dbs/$DatabaseId/colls/$CollectionId"
$keyType = "master" 
$tokenVersion = "1.0"
$dateTime = [DateTime]::UtcNow.ToString("r")
$queryUri = "$EndPoint$ResourceLink/docs"
$PkeyOrderID = '"' + $DatabaseOrderID + '"'
$pkey = "[ $PKeyOrderID ]"

# authentication
$hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
$hmacSha256.Key = [System.Convert]::FromBase64String($DatabaseSigningKey)
$payLoad = "$($method.ToLowerInvariant())`n$($resourceType.ToLowerInvariant())`n$ResourceLink`n$($dateTime.ToLowerInvariant())`n`n"
$hashPayLoad = $hmacSha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payLoad))
$signature = [System.Convert]::ToBase64String($hashPayLoad);
$authHeader = [System.Web.HttpUtility]::UrlEncode("type=$keyType&ver=$tokenVersion&sig=$signature")

    

$header = @{authorization=$authHeader;"x-ms-version"="2017-02-22";"x-ms-date"=$dateTime;"x-ms-documentdb-partitionkey"= $pkey;}

Invoke-RestMethod -Method $Method -ContentType $contentType -Uri $queryUri -Headers $header -Body $Body 

