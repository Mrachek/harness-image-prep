param(
  [Parameter(Mandatory = $false)]
  [string]$ImageTag = "local/custom-image:dev"
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker CLI is not available in this terminal."
}

$failures = New-Object System.Collections.Generic.List[string]

Write-Host "Verifying Python version in $ImageTag"
try {
  $pythonVersion = docker run --rm $ImageTag python3 --version
  $pythonVersionMatch = [regex]::Match($pythonVersion, 'Python\s+([0-9]+\.[0-9]+\.[0-9]+)')
  if (-not $pythonVersionMatch.Success) {
    $failures.Add("Could not parse Python version from: $pythonVersion")
  } elseif ([version]$pythonVersionMatch.Groups[1].Value -lt [version]'3.12.10') {
    $failures.Add("Expected Python 3.12.10 or newer, but got: $pythonVersion")
  } else {
    Write-Host "Python check passed: $pythonVersion"
  }
} catch {
  $failures.Add("Python check failed: $($_.Exception.Message)")
}

Write-Host "Verifying wheel build in $ImageTag"
try {
  $wheelCheck = @'
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(tempfile.mkdtemp(prefix="wheel-check-"))
(root / "demo_pkg").mkdir()
(root / "demo_pkg" / "__init__.py").write_text("__version__ = '0.1.0'\n", encoding="utf-8")
(root / "pyproject.toml").write_text("""\
[build-system]
requires = ["setuptools>=61", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "demo-pkg"
version = "0.1.0"
""", encoding="utf-8")

dist_dir = root / "dist"
dist_dir.mkdir()
subprocess.run([sys.executable, "-m", "pip", "wheel", "--no-deps", "--wheel-dir", str(dist_dir), str(root)], check=True)
wheel_files = list(dist_dir.glob("*.whl"))
if not wheel_files:
    raise SystemExit("No wheel file was produced")
print(wheel_files[0].name)
'@
  $wheelOutput = (docker run --rm $ImageTag python3 -c $wheelCheck) -join ' '
  if ($wheelOutput -notmatch '\.whl') {
    $failures.Add("Wheel build did not produce a wheel file. Output: $wheelOutput")
  } else {
    Write-Host "Wheel check passed: $wheelOutput"
  }
} catch {
  $failures.Add("Wheel build check failed: $($_.Exception.Message)")
}

Write-Host "Verifying databricks-cli version in $ImageTag"
try {
  $cliBinaryVersion = (docker run --rm $ImageTag databricks --version) -join ' '
  if ($cliBinaryVersion -notmatch '1\.2\.1') {
    $failures.Add("Expected Databricks CLI v1.2.1, but got:`n$cliBinaryVersion")
  } else {
    Write-Host "databricks binary check passed: $cliBinaryVersion"
  }
} catch {
  $failures.Add("databricks-cli check failed: $($_.Exception.Message)")
}

if ($failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Validation failed:"
  $failures | ForEach-Object { Write-Host "- $_" }
  exit 1
}

Write-Host "All checks passed."
