param (
    [string]$RepositoryOwner = "thnetii",
    [string]$RepositoryName = "docs",
    [string]$TargetFolder = "gh-pages"
)

[uri] $RepositorBaseUrl = "https://github.com/$RepositoryOwner/$RepositoryName.git"

$git = Get-Command -CommandType Application "git"
& "$git" clone "$RepositorBaseUrl" -- "$TargetFolder"
