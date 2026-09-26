# Identifiers

> Draft normative text.

`disc.identifiers` is a required, non-empty array of `{kind, value}` pairs.

| `kind` | Meaning |
| --- | --- |
| `thediscdb-content-hash` | Size-derived disc content hash. **Required.** |
| `aacs-disc-id` | AACS disc identifier, when observed. |
| `dvd-disc-id` | DVD disc identifier, when observed. |
| `matrix256` | Legacy producer-computed disc fingerprint, when available. |

Every manifest contains exactly one `thediscdb-content-hash` entry. It is the
stable join key between a manifest and an existing catalog entry, and it is
derived entirely from the file inventory, so any producer that can enumerate
the disc can compute it without reading payload bytes.

All other kinds are optional and may appear at most once. `matrix256` is
retained for compatibility with producers that already emit it; its derivation
is not specified here, and consumers must not treat it as a join key.

## Deriving `thediscdb-content-hash`

The derivation is byte-exact. Producers that deviate will not match existing
catalog entries.

1. **Select** the payload files from `disc.files`:
   - Blu-ray and UHD Blu-ray: paths matching `BDMV/STREAM/<name>.m2ts`.
   - DVD: paths under `VIDEO_TS/` with a `.VOB`, `.IFO`, or `.BUP` extension.

   Exclude everything under `BDMV/BACKUP/`, and exclude `.ssif` files. Matching
   is case-insensitive.

2. **Key each selected file on its bare filename**, discarding the directory
   portion. `BDMV/STREAM/00800.m2ts` sorts as `00800.m2ts`.

3. **Sort** the filenames ascending using an ordinal (byte-value) comparison,
   not a culture-aware or case-insensitive one.

4. **Concatenate** each file's `sizeBytes` as an 8-byte little-endian signed
   integer, in that order. No separators, no path bytes, and no length prefix
   are included.

5. **Hash** the concatenated buffer with MD5 and render it as 32 uppercase
   hexadecimal characters.

MD5 is used because it is what the existing catalog already stores. This value
identifies a disc pressing; it is not a security or integrity control, and it
must not be treated as one.

Because only `sizeBytes` contributes, two manifests describing the same
pressing agree regardless of capture tool, capture order, or which non-payload
files were recorded.

`tools/validate/Get-ContentHash.ps1` is the reference implementation and can
recompute or verify the value for any manifest.
