<#
.SYNOPSIS
    Reference implementation of the matrix256 identifier computed from disc.files.

.DESCRIPTION
    Implements matrix256 version 1 (https://github.com/shitwolfymakes/matrix256/blob/main/SPEC.md)
    over a manifest's disc.files[] inventory instead of a mounted filesystem:

      1. NFC-normalize each path and encode it as UTF-8.
      2. Sort entries by those bytes (byte-wise, like memcmp).
      3. For each entry emit: <path bytes> 0x00 <size as base-10 ASCII> 0x0A.
      4. SHA-256 the result and render 64 lowercase hex characters.

    Use -Files to hash an ad-hoc list of { path, sizeBytes } objects.

.EXAMPLE
    ./Get-Matrix256.ps1 -Path ../examples/v1/blu-ray/basic.json
#>
[CmdletBinding(DefaultParameterSetName = 'Manifest')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Manifest', ValueFromPipeline)]
    [string[]] $Path,

    [Parameter(Mandatory, ParameterSetName = 'Files')]
    [AllowEmptyCollection()]
    [object[]] $Files
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    function Get-Matrix256 {
        param([object[]] $Entries)

        $utf8 = [System.Text.UTF8Encoding]::new($false)
        $records = foreach ($entry in $Entries) {
            [pscustomobject]@{
                PathBytes = $utf8.GetBytes(([string] $entry.path).Normalize([System.Text.NormalizationForm]::FormC))
                Size      = [long] $entry.sizeBytes
            }
        }
        $records = @($records)

        $comparison = [System.Comparison[object]] {
            param($a, $b)
            $x = $a.PathBytes; $y = $b.PathBytes
            $n = [Math]::Min($x.Length, $y.Length)
            for ($i = 0; $i -lt $n; $i++) {
                if ($x[$i] -ne $y[$i]) { return [int] $x[$i] - [int] $y[$i] }
            }
            return $x.Length - $y.Length
        }
        $list = [System.Collections.Generic.List[object]]::new([object[]] $records)
        $list.Sort($comparison)

        $buffer = [System.IO.MemoryStream]::new()
        foreach ($record in $list) {
            $buffer.Write($record.PathBytes, 0, $record.PathBytes.Length)
            $buffer.WriteByte(0x00)
            $sizeBytes = [System.Text.Encoding]::ASCII.GetBytes($record.Size.ToString([System.Globalization.CultureInfo]::InvariantCulture))
            $buffer.Write($sizeBytes, 0, $sizeBytes.Length)
            $buffer.WriteByte(0x0A)
        }

        [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($buffer.ToArray())).ToLowerInvariant()
    }
}

process {
    if ($PSCmdlet.ParameterSetName -eq 'Files') {
        return Get-Matrix256 -Entries $Files
    }

    foreach ($item in $Path) {
        $resolved = (Resolve-Path -LiteralPath $item).Path
        $manifest = Get-Content -LiteralPath $resolved -Raw | ConvertFrom-Json

        $filesProperty = $manifest.disc.PSObject.Properties['files']
        if (-not $filesProperty -or @($filesProperty.Value).Count -eq 0) {
            throw "$resolved carries no disc.files inventory, so matrix256 cannot be derived."
        }

        $declared = @($manifest.disc.identifiers) |
            Where-Object { $_.kind -eq 'matrix256' } |
            Select-Object -ExpandProperty value -First 1

        $computed = Get-Matrix256 -Entries @($filesProperty.Value)

        [pscustomobject]@{
            Path     = $resolved
            Computed = $computed
            Declared = $declared
            Matches  = ($declared -ceq $computed)
        }
    }
}
