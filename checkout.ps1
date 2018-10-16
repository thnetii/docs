$ErrorActionPreference = "Stop"
param (
    [string]$RepositoryOwner = "thnetii",
    [string]$RepositoryName = "docs",
    [string]$TargetFolder = "gh-pages"
)

[uri] $RepositorBaseUrl = "https://github.com/$RepositoryOwner/$RepositoryName.git"

if (Test-Path $TargetFolder) {
    Remove-Item -Recurse -Verbose -Path $TargetFolder
}

$git = Get-Command -CommandType Application "git" | Select-Object -First 1
& "$git" clone "$RepositorBaseUrl" -- "$TargetFolder"
