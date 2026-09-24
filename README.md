# Optical Disc Manifest

Optical Disc Manifest is a versioned, tool-neutral JSON format for recording
the observed structure of DVD, Blu-ray, and UHD Blu-ray discs.

An Optical Disc Manifest records evidence such as:

- disc format and identifiers;
- complete file inventory;
- DVD title sets, PGCs, cells, chapters, and angles;
- Blu-ray playlists, clips, play marks, and subpaths;
- declared video, audio, and subtitle streams;
- producer identity and explicit observation capabilities.

It deliberately excludes human classification such as movie, episode, main
feature, deleted scene, or editorial description. Those decisions belong to
applications consuming the manifest.

> **Status: pre-release draft.** No released version exists yet. The v1 schema
> and semantics may change incompatibly until the first release candidate.

## Name and identifiers

- Formal name: **Optical Disc Manifest**
- Suggested filename suffix: **`.odm.json`**
- Draft media type: **`application/vnd.thediscdb.optical-disc-manifest+json`**
- Repository: **`TheDiscDb/optical-disc-manifest`**
- Draft schema: [`schemas/v1/optical-disc-manifest.schema.json`](schemas/v1/optical-disc-manifest.schema.json)

“ODM” is a convenient filename abbreviation, not the normative format name.

## Repository map

| Path | Purpose |
|------|---------|
| `schemas/` | Versioned JSON Schemas |
| `specification/` | Normative semantics beyond JSON Schema |
| `examples/` | Small explanatory manifests |
| `conformance/` | Machine-tested valid and invalid documents |
| `test-data/` | Redistributable optical-disc metadata fixtures |
| `tools/` | Reference conformance tooling |
| `rfcs/` | Proposed substantive changes |
| `decisions/` | Accepted durable design decisions |

## Validate the draft

PowerShell 7.4 or later is required:

```powershell
pwsh ./tools/validate/Test-Conformance.ps1
```

## Design principles

1. Record observed disc structure, not editorial interpretation.
2. Make absent, empty, unsupported, and partially read data distinguishable.
3. Do not require media decryption or full VOB/M2TS payload reads.
4. Use portable relative paths, exact byte counts, and numeric seconds.
5. Keep submitted values untrusted and independently verifiable.
6. Define deterministic serialization for stable hashes and review diffs.
7. Preserve format-specific identity rather than flattening DVD and Blu-ray.

See the [v1 specification overview](specification/v1/model.md) and
[contribution guide](CONTRIBUTING.md).
