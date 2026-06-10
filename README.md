# harness-image-prep

Minimal local workflow for building and testing a container image before using it in Harness.

## Prerequisites

- Docker Desktop installed and running
- Access to the Dockerfile source that defines the image
- If pulling from GHCR, a GitHub PAT with `read:packages`

Current Dockerfile path:

- `images/image1/DockerFile`

## Build

```powershell
.\scripts\build-image.ps1 -DockerfilePath .\images\image1\DockerFile -ContextPath .\images\image1 -ImageTag local/custom-image:dev
```

## Smoke test

For a CLI image:

```powershell
.\scripts\smoke-test.ps1 -ImageTag local/custom-image:dev -CommandArgs "--help"
```

For a service image, replace the command with the container's normal startup or health check flow.

Validation script:

```powershell
.\scripts\test-image.ps1 -ImageTag local/custom-image:dev
```

## GHCR login

If you need to pull from GitHub Container Registry:

```powershell
docker login ghcr.io -u YOUR_GITHUB_USERNAME
```

Use a PAT with `read:packages` as the password.
