param(
  [Parameter(Mandatory = $true)]
  [string]$ImageTag,

  [Parameter(Mandatory = $false)]
  [string[]]$CommandArgs = @("--help")
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker CLI is not available in this terminal."
}

Write-Host "Running smoke test for $ImageTag"

if (-not $CommandArgs -or $CommandArgs.Count -eq 0) {
  docker run --rm $ImageTag
} else {
  docker run --rm $ImageTag @CommandArgs
}
