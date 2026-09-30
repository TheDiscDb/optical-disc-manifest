<#
.SYNOPSIS
    Reference implementation of the thediscdb-content-hash recipe.

.DESCRIPTION
    Computes the thediscdb-content-hash identifier from a manifest's own disc.files[]
    inventory, following the normative recipe in specification/v1/README.md.

    The recipe is deliberately executable here because a wrong MD5 is
    indistinguishable from a right one: a producer that selects the wrong files, keys
    on the path instead of the bare filename, or hashes anything other than the
    little-endian sizes still emits a plausible-looking 32-character hex string.

.PARAMETER Path
    Path to an Optical Disc Manifest JSON document.

.PARAMETER Verify
    Compare the computed value against the thediscdb-content-hash entry already
    present in the document and fail when they disagree.

.EXAMPLE
    ./Get-ContentHash.ps1 -Path ../examples/v1/blu-ray/basic.json -Verify
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string[]] $Path,

    [switch] $Verify
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    function Get-HashInput {
        param($Manifest)

        $filesProperty = $Manifest.disc.PSObject.Properties['files']
        $files = if ($filesProperty) { @($filesProperty.Value) } else { @() }
        if ($files.Count -eq 0) {
            throw 'The manifest carries no disc.files inventory, so the content hash cannot be derived.'
        }

        # Step 1 - select. BACKUP copies and SSIF interleave containers are never hashed.
        $selected = switch ($Manifest.disc.format) {
            'dvd' {
                $files | Where-Object {
                    $_.path -like 'VIDEO_TS/*' -and
                    [System.IO.Path]::GetExtension($_.path) -in @('.VOB', '.IFO', '.BUP')
                }
            }
            default {
                $files | Where-Object {
                    $_.path -like 'BDMV/STREAM/*' -and
                    $_.path -notlike 'BDMV/BACKUP/*' -and
                    [System.IO.Path]::GetExtension($_.path) -eq '.m2ts'
                }
            }
        }

        $selected = @($selected)
        if ($selected.Count -eq 0) {
            throw "No hashable media files were found for a '$($Manifest.disc.format)' disc."
        }

        # Step 2 and 3 - key on the bare filename, sort ordinal (byte-value) ascending.
        $entries = @($selected | ForEach-Object {
            [pscustomobject]@{ Name = [System.IO.Path]::GetFileName($_.path); Size = [long] $_.sizeBytes }
        })
        $names = [string[]] @($entries.Name)
        $items = [object[]] $entries
        [System.Array]::Sort($names, $items, [System.StringComparer]::Ordinal)
        $items
    }
}

process {
    foreach ($item in $Path) {
        $resolved = (Resolve-Path -LiteralPath $item).Path
        $manifest = Get-Content -LiteralPath $resolved -Raw | ConvertFrom-Json

        $entries = @(Get-HashInput -Manifest $manifest)

        # Step 4 - MD5 over each size as an 8-byte little-endian long, no separators
        # and no path bytes.
        $buffer = [System.Collections.Generic.List[byte]]::new()
        foreach ($entry in $entries) {
            $bytes = [System.BitConverter]::GetBytes($entry.Size)
            if (-not [System.BitConverter]::IsLittleEndian) {
                [System.Array]::Reverse($bytes)
            }
            $buffer.AddRange($bytes)
        }

        $md5 = [System.Security.Cryptography.MD5]::Create()
        try {
            $digest = $md5.ComputeHash($buffer.ToArray())
        }
        finally {
            $md5.Dispose()
        }

        # Step 5 - uppercase hex, no separators.
        $computed = [System.Convert]::ToHexString($digest)

        $identifierProperty = $manifest.disc.PSObject.Properties['identifiers']
        $declared = if ($identifierProperty) {
            @($identifierProperty.Value) |
                Where-Object { $_.kind -eq 'thediscdb-content-hash' } |
                Select-Object -ExpandProperty value -First 1
        }

        $result = [pscustomobject]@{
            Path      = $resolved
            Format    = $manifest.disc.format
            FileCount = $entries.Count
            Computed  = $computed
            Declared  = $declared
            Matches   = ($declared -eq $computed)
        }

        if ($Verify -and -not $result.Matches) {
            Write-Error "$resolved : declared '$declared' but recomputed '$computed' from $($entries.Count) file(s)."
        }

        $result
    }
}
