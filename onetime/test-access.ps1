if ([string]::IsNullOrWhiteSpace($env:GHCR_PAT)) {
  throw "Set GHCR_PAT to a GitHub token with read:packages before running this script."
}

if ([string]::IsNullOrWhiteSpace($env:GHCR_USERNAME)) {
  throw "Set GHCR_USERNAME to your GitHub username before running this script."
}

$env:GHCR_PAT | docker login ghcr.io -u $env:GHCR_USERNAME --password-stdin
Remove-Item Env:\GHCR_PAT

docker pull ghcr.io/es-ce-testing-portfolio/edp-custom-image:build-64
