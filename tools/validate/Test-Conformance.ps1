[CmdletBinding()]
param(
    [string] $RepositoryRoot = (Join-Path $PSScriptRoot '..' '..')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$schema = Join-Path $root 'schemas' 'v1' 'optical-disc-manifest.schema.json'
$manifestPath = Join-Path $root 'conformance' 'manifest.json'
$contentHashTool = Join-Path $PSScriptRoot 'Get-ContentHash.ps1'

# Fail loudly rather than silently validating nothing: a missing schema or an
# empty case list would otherwise let this script report success.
foreach ($required in $schema, $manifestPath, $contentHashTool) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required file not found: $required"
    }
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$cases = @($manifest.cases)
if ($cases.Count -eq 0) {
    throw "No conformance cases are declared in $manifestPath."
}

$failures = [System.Collections.Generic.List[string]]::new()
$hashChecked = [System.Collections.Generic.List[string]]::new()
$unverifiable = [System.Collections.Generic.List[string]]::new()

# disc.files is optional, so a manifest can declare a content hash it does not carry the
# evidence to prove. Such a hash is asserted, not verifiable: recompute the ones we can and
# account for the rest separately rather than reporting them as failures.
function Test-HashVerifiable {
    param([string] $DocumentPath)

    $document = Get-Content -LiteralPath $DocumentPath -Raw | ConvertFrom-Json
    $filesProperty = $document.disc.PSObject.Properties['files']
    if (-not $filesProperty) { return $false }
    return @($filesProperty.Value).Count -gt 0
}

foreach ($case in $cases) {
    $path = Join-Path $root 'conformance' $case.path
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("$($case.path): declared in manifest.json but the file is missing.")
        continue
    }

    $actual = Test-Json -LiteralPath $path -SchemaFile $schema -ErrorAction SilentlyContinue
    if ($actual -ne $case.valid) {
        $failures.Add("$($case.path): expected valid=$($case.valid), actual=$actual")
    }

    if ($case.valid) {
        if (Test-HashVerifiable -DocumentPath $path) { $hashChecked.Add($path) }
        else { $unverifiable.Add($path) }
    }
}

$examples = @(Get-ChildItem -LiteralPath (Join-Path $root 'examples') -Recurse -File -Filter '*.json')
if ($examples.Count -eq 0) {
    throw 'No examples were found to validate.'
}

foreach ($example in $examples) {
    if (-not (Test-Json -LiteralPath $example.FullName -SchemaFile $schema -ErrorAction SilentlyContinue)) {
        $failures.Add("Example failed schema validation: $($example.FullName)")
    }
    else {
        if (Test-HashVerifiable -DocumentPath $example.FullName) { $hashChecked.Add($example.FullName) }
        else { $unverifiable.Add($example.FullName) }
    }
}

# The schema can only require that a content hash is present. Because the value is
# the catalog join key, recompute it here so a wrong-but-well-formed hash cannot land.
foreach ($document in $hashChecked) {
    try {
        $result = & $contentHashTool -Path $document
        if (-not $result.Matches) {
            $failures.Add("$document : thediscdb-content-hash is '$($result.Declared)' but recomputes to '$($result.Computed)'.")
        }
    }
    catch {
        $failures.Add("$document : content hash could not be recomputed. $($_.Exception.Message)")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

Write-Output ('Optical Disc Manifest conformance cases passed ({0} case(s), {1} example(s), {2} content hash(es) verified, {3} asserted but unverifiable).' -f
    $cases.Count, $examples.Count, $hashChecked.Count, $unverifiable.Count)
