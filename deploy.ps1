param (
    [string]$Authorization,
    [string]$RepositoryOwner = "thnetii",
    [string]$RepositoryName = "docs",
    [string]$ArtifactName = [System.Guid]::NewGuid().ToString(),
    [string]$MergeTargetBranch = "master",
    [string]$GitUserName = "Unknown User",
    [string]$GitUserEmail = "unknown@unknown.com"
)

Write-Host "AUTHORIZATION: bearer $Authorization"

[uri] $RepositoryUrl = "https://github.com/$RepositoryOwner/$RepositoryName.git"
$git = Get-Command -CommandType Application "git" | Select-Object -First 1

& "$git" config user.name "$GitUserName"
& "$git" config user.Email "$GitUserEmail"
& "$git" status
& "$git" checkout -b "$ArtifactName"
& "$git" add -f .
& "$git" commit --allow-empty -m "Artifact Deployment: $ArtifactName"
& "$git" -c http.extraheader="AUTHORIZATION: bearer $Authorization" push -f "$RepositoryUrl" "$ArtifactName"

$pullJson = @{
    title = "Merge $ArtifactName into $MergeTargetBranch"
    body = "Automated Pull Request Created by Deployment Script"
    head = "$ArtifactName"
    base = "$MergeTargetBranch"
    maintainer_can_modify = $true
} | ConvertTo-Json
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[uri] $pullUri = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/pulls"
$githubAuthorizationHeader = @{ "Authorization" = "bearer $Authorization" }
$pullResponse = Invoke-RestMethod -Uri $pullUri  -Method Post -ContentType "application/json" `
    -Headers $githubAuthorizationHeader `
    -Body $pullJson -Verbose
$pullNumber = $pullResponse.number
[uri] $pullMergeUri = "$pullUri/$pullNumber/merge"
$mergeJson = @{} | ConvertTo-Json
$mergeResponse = Invoke-RestMethod -Uri $pullMergeUri -Method Put -ContentType "application/json" `
    -Headers $githubAuthorizationHeader `
    -Body $mergeJson -Verbose
Write-Host $mergeResponse
