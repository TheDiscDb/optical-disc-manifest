[CmdletBinding()]
param(
    [string] $RepositoryRoot = (Join-Path $PSScriptRoot '..\..')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$schema = Join-Path $root 'schemas\v1\optical-disc-manifest.schema.json'
$manifestPath = Join-Path $root 'conformance\manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$failures = [System.Collections.Generic.List[string]]::new()

foreach ($case in $manifest.cases) {
    $path = Join-Path (Join-Path $root 'conformance') $case.path
    $actual = Test-Json -LiteralPath $path -SchemaFile $schema -ErrorAction SilentlyContinue
    if ($actual -ne $case.valid) {
        $failures.Add("$($case.path): expected valid=$($case.valid), actual=$actual")
    }
}

foreach ($example in Get-ChildItem -LiteralPath (Join-Path $root 'examples') -Recurse -File -Filter '*.json') {
    if (-not (Test-Json -LiteralPath $example.FullName -SchemaFile $schema -ErrorAction SilentlyContinue)) {
        $failures.Add("Example failed schema validation: $($example.FullName)")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Optical Disc Manifest conformance cases passed."
