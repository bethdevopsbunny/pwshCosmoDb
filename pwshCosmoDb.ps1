            function Connect-CosmoDB {
                param (
                    $EndPoint,
                    $DatabaseId,
                    $CollectionId,
                    $DatabaseSigningKey,
                    $Method,
                    $Body,
                    $DatabaseOrderID
                    )
                    
                    
                    $ResourceType = "docs";
                    $ResourceLink = "dbs/$DatabaseId/colls/$CollectionId"
                    $keyType = "master" 
                    $tokenVersion = "1.0"
                    $dateTime = [DateTime]::UtcNow.ToString("r")
                    $hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
                    $hmacSha256.Key = [System.Convert]::FromBase64String($DatabaseSigningKey)
                    $payLoad = "$($method.ToLowerInvariant())`n$($resourceType.ToLowerInvariant())`n$resourceLink`n$($dateTime.ToLowerInvariant())`n`n"
                    $hashPayLoad = $hmacSha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payLoad))
                    $signature = [System.Convert]::ToBase64String($hashPayLoad);
                    $authHeader = [System.Web.HttpUtility]::UrlEncode("type=$keyType&ver=$tokenVersion&sig=$signature")
                    $queryUri = "$EndPoint$ResourceLink/docs"
            
                    switch ($Method) {
                        GET {
                            
                            $header = @{authorization=$authHeader;"x-ms-version"="2017-02-22";"x-ms-date"=$dateTime;}
                            $result = Invoke-RestMethod -Method $Method -Uri $queryUri -Headers $header -ContentType $contentType  
                        }
                        POST{ 
                            
                            $PkeyOrderID = '"' + $DatabaseOrderID + '"'
                            $pkey = "[ $PKeyOrderID ]"
                            
                            $header = @{authorization=$authHeader;"x-ms-version"="2017-02-22";"x-ms-date"=$dateTime;"x-ms-documentdb-partitionkey"= $pkey;}
                            
                            $result = Invoke-RestMethod -Method $Method -ContentType $contentType -Uri $queryUri -Headers $header -Body $Body 
                        }
                        Default {}
                    }
                    
                    
                    return $result
                    
                    
                    
                }

$result = Connect-CosmoDB -Method GET -EndPoint $EndPoint  -DatabaseId $DatabaseId -CollectionId $CollectionId -DatabaseSigningKey $DatabaseSigningKey
$result = Connect-CosmoDB -Method POST -Body $DatabasePayloadJson -DatabaseOrderID $DatabasePayload.id -EndPoint $EndPoint  -DatabaseId $DatabaseId -CollectionId $CollectionId -DatabaseSigningKey $DatabaseSigningKey
                            
    