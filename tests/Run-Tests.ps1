<#
.SYNOPSIS
    Runs the Optical Disc Manifest test suite.

.DESCRIPTION
    - Every document in tests/valid/ and examples/ MUST pass.
    - Every document in tests/invalid/ MUST fail. Its filename states the reason.

    A document passes when it validates against the JSON Schema and passes the
    semantic checks the schema cannot express:

      - title.chapterCount equals the length of title.chapters when both are present;
      - disc.files paths are unique (after NFC normalization);
      - when disc.files is present, thediscdb-content-hash and matrix256 (if
        declared) recompute to the declared values.

    Requires PowerShell 7.4 or later.
#>
[CmdletBinding()]
param(
    [string] $RepositoryRoot = (Join-Path $PSScriptRoot '..')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$schema = Join-Path $root 'schemas' 'v1' 'optical-disc-manifest.schema.json'
$contentHashTool = Join-Path $PSScriptRoot 'Get-ContentHash.ps1'
$matrix256Tool = Join-Path $PSScriptRoot 'Get-Matrix256.ps1'

foreach ($required in $schema, $contentHashTool, $matrix256Tool) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required file not found: $required" }
}

function Get-Json([string] $Directory) {
    @(Get-ChildItem -LiteralPath $Directory -Recurse -File -Filter '*.json' | Sort-Object FullName)
}

$valid = @(Get-Json (Join-Path $PSScriptRoot 'valid')) + @(Get-Json (Join-Path $root 'examples'))
$invalid = @(Get-Json (Join-Path $PSScriptRoot 'invalid'))
if ($valid.Count -eq 0 -or $invalid.Count -eq 0) { throw 'No test documents were found.' }

# Returns the reasons a document is not a conforming manifest; empty when it conforms.
function Get-Problems([string] $DocumentPath) {
    $problems = [System.Collections.Generic.List[string]]::new()

    $schemaErrors = $null
    if (-not (Test-Json -LiteralPath $DocumentPath -SchemaFile $schema -ErrorAction SilentlyContinue -ErrorVariable schemaErrors)) {
        # contains/if subschemas report every non-matching identifier kind; drop that noise.
        $messages = @($schemaErrors | ForEach-Object { $_.Exception.Message -replace '^The JSON is not valid with the schema: ', '' } |
            Where-Object { $_ -notmatch "^Expected .* at '/disc/identifiers/\d+/kind'$" })
        $problems.Add('schema: ' + ($messages -join '; '))
        return $problems
    }

    $document = Get-Content -LiteralPath $DocumentPath -Raw | ConvertFrom-Json

    $titlesProperty = $document.disc.PSObject.Properties['titles']
    $titleIndex = 0
    foreach ($title in @(if ($titlesProperty) { $titlesProperty.Value })) {
        $countProperty = $title.PSObject.Properties['chapterCount']
        $chaptersProperty = $title.PSObject.Properties['chapters']
        if ($countProperty -and $chaptersProperty -and $countProperty.Value -ne @($chaptersProperty.Value).Count) {
            $problems.Add("titles[$titleIndex].chapterCount is $($countProperty.Value) but chapters has $(@($chaptersProperty.Value).Count) entries")
        }
        $titleIndex++
    }

    $filesProperty = $document.disc.PSObject.Properties['files']
    if (-not $filesProperty) { return $problems }

    $paths = @($filesProperty.Value | ForEach-Object { ([string] $_.path).Normalize([System.Text.NormalizationForm]::FormC) })
    $duplicates = @($paths | Group-Object -CaseSensitive | Where-Object Count -gt 1 | ForEach-Object Name)
    if ($duplicates.Count -gt 0) { $problems.Add("duplicate file path(s): $($duplicates -join ', ')") }

    $contentHash = & $contentHashTool -Path $DocumentPath
    if (-not $contentHash.Matches) {
        $problems.Add("thediscdb-content-hash is '$($contentHash.Declared)' but recomputes to '$($contentHash.Computed)'")
    }

    $matrix256 = & $matrix256Tool -Path $DocumentPath
    if ($matrix256.Declared -and -not $matrix256.Matches) {
        $problems.Add("matrix256 is '$($matrix256.Declared)' but recomputes to '$($matrix256.Computed)'")
    }

    return $problems
}

$failed = 0
foreach ($file in $valid) {
    $name = [System.IO.Path]::GetRelativePath($root, $file.FullName)
    $problems = @(try { Get-Problems $file.FullName } catch { "error: $($_.Exception.Message)" })
    if ($problems.Count -eq 0) { Write-Host "PASS  $name" }
    else { $failed++; Write-Host "FAIL  $name (expected valid)`n      $($problems -join "`n      ")" -ForegroundColor Red }
}

foreach ($file in $invalid) {
    $name = [System.IO.Path]::GetRelativePath($root, $file.FullName)
    $problems = @(try { Get-Problems $file.FullName } catch { "error: $($_.Exception.Message)" })
    if ($problems.Count -gt 0) { Write-Host "PASS  $name`n      rejected: $($problems[0])" }
    else { $failed++; Write-Host "FAIL  $name (expected invalid, but it was accepted)" -ForegroundColor Red }
}

$total = $valid.Count + $invalid.Count
Write-Host ("`n{0} passed, {1} failed, {2} total" -f ($total - $failed), $failed, $total)
if ($failed -gt 0) { exit 1 }
