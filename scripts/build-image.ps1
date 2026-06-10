param(
  [Parameter(Mandatory = $false)]
  [string]$DockerfilePath = "images/image1/DockerFile",

  [Parameter(Mandatory = $false)]
  [string]$ContextPath = "images/image1",

  [Parameter(Mandatory = $false)]
  [string]$ImageTag = "local/custom-image:dev"
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker CLI is not available in this terminal."
}

if (-not (Test-Path -LiteralPath $DockerfilePath)) {
  throw "Dockerfile not found: $DockerfilePath"
}

Write-Host "Building $ImageTag from $DockerfilePath with context $ContextPath"
docker build -f $DockerfilePath -t $ImageTag $ContextPath
