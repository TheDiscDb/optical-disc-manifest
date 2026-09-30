# Optical Disc Manifest

A tool-neutral JSON format that records what was **observed** on a DVD,
Blu-ray, or UHD Blu-ray disc: its identifiers, complete file inventory, titles,
chapters, segments, and declared streams. It does not record editorial
classification such as "main feature" or "episode".

> **Status: draft.** v1 may change incompatibly until `v1.0.0` is tagged.

| | |
|---|---|
| Specification | [`specification/v1`](specification/v1/README.md) |
| JSON Schema | [`schemas/v1/optical-disc-manifest.schema.json`](schemas/v1/optical-disc-manifest.schema.json) |
| Examples | [`examples/v1`](examples/v1) |
| Tests | [`tests`](tests) |
| Filename suffix | `.odm.json` |
| Media type (draft) | `application/vnd.thediscdb.optical-disc-manifest+json` |

## Minimal manifest

```json
{
  "schemaVersion": 1,
  "producer": { "name": "my-scanner", "version": "1.0.0" },
  "disc": {
    "format": "blu-ray",
    "identifiers": [
      { "kind": "thediscdb-content-hash", "value": "D86ABC728DF7FB7A74E6FABFFC1BD47C" }
    ],
    "files": [
      { "path": "BDMV/STREAM/00001.m2ts", "sizeBytes": 1024 }
    ]
  }
}
```

## Running the tests

The test suite checks every file in `tests/valid` and `examples` (each must
pass) and every file in `tests/invalid` (each must fail; the filename gives
the reason). It requires [PowerShell 7.4+](https://aka.ms/powershell):

```powershell
pwsh ./tests/Run-Tests.ps1
```

`tests/Get-ContentHash.ps1` and `tests/Get-Matrix256.ps1` are reference
implementations of the two derived identifiers.

## License

[Apache 2.0](LICENSE)