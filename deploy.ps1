param (
    [string]$AccessToken,
    [string]$RepositoryOwner = "thnetii",
    [string]$RepositoryName = "docs",
    [string]$ArtifactName = [System.Guid]::NewGuid().ToString(),
    [string]$MergeTargetBranch = "master"
)
$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$GitHubUser = Invoke-RestMethod -Uri "https://api.github.com/user?access_token=$AccessToken" -Method Get -Verbose
$GitUserName = $GitHubUser.login
$GitUserEmail = $GitHubUser.email

[uri] $RepositoryUrl = "https://$($AccessToken):x-oauth-basic@github.com/$RepositoryOwner/$RepositoryName.git"
$git = Get-Command -CommandType Application "git" | Select-Object -First 1

if ($GitUserName -or $GitUserEmail) {
    & "$git" config user.name "$GitUserName"
    & "$git" config user.Email "$GitUserEmail"
}
& "$git" status
& "$git" checkout -b "$ArtifactName"
& "$git" add -f .
& "$git" commit --allow-empty -m "Artifact Deployment: $ArtifactName"
& "$git" push -f "$RepositoryUrl" "$ArtifactName"

$pullJson = @{
    title = "Merge $ArtifactName into $MergeTargetBranch"
    body = "Automated Pull Request Created by Deployment Script"
    head = "$ArtifactName"
    base = "$MergeTargetBranch"
    maintainer_can_modify = $true
} | ConvertTo-Json
$pullBase = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/pulls"
$pullUri = [uri] "$($pullBase)?access_token=$($AccessToken)"
$pullResponse = Invoke-RestMethod -Uri $pullUri -Method Post -ContentType "application/json" `
    -Body $pullJson -Verbose
$pullNumber = $pullResponse.number
$pullMergeUri = [uri] "$($pullBase)/$($pullNumber)/merge?access_token=$($AccessToken)"
$mergeJson = @{} | ConvertTo-Json
$mergeResponse = Invoke-RestMethod -Uri $pullMergeUri -Method Put -ContentType "application/json" `
    -Body $mergeJson -Verbose
$mergeResponse | Format-List
