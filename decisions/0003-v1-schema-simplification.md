# Decision 0003: v1 schema simplification and a required content hash

- Status: accepted
- Date: 2026-02-14
- RFC: [0002-simplify-v1-before-release-candidate](../rfcs/0002-simplify-v1-before-release-candidate.md)

## Decision

Apply the following changes to the draft v1 schema. `schemaVersion` remains 1
because nothing has been released.

### Removed

| Removed | Reason |
| --- | --- |
| `capabilities` (and its conditional rules) | Producer claims, not disc evidence; unconditionally present, so never discriminating. |
| `diagnostics` | Parser behavior belongs in producer logs. |
| `index` on titles, chapters, segments, streams | JSON array order already conveys ordering. |
| `durationTicks45k`, `startTicks45k` on titles, chapters, segments, clips | Seconds are lossless for these values. |
| `title.chapterCount` | Equals `chapters.length`. |
| `file.role` | Derivable from the path and extension. |
| `segment.filePath` | The referenced clip already carries its path. |
| `clip.sizeBytes` | The file inventory already carries it. |
| `legacy-disc-hash` identifier kind | Renamed to `thediscdb-content-hash`. |

### Changed

`title.source` collapses from a six-variant `oneOf` to a flat object
`{path?, title?, titleSet?, titleSetTitle?}` with `minProperties: 1`. Its
`path` pattern accepts `BDMV/BACKUP/PLAYLIST/...` so that a manifest can still
record a playlist read from the backup copy, which was previously signalled
through `diagnostics`.

`disc.identifiers` becomes required, must contain at least one entry, and must
contain a `thediscdb-content-hash` entry.

### Added

`stream.category`, `stream.frameRate`, `stream.isInterlaced`,
`stream.sampleRate`, and a `menu` value for `stream.type`.

### Retained deliberately

- `syncPresentationTimestampTicks45k`: the authored MVC synchronization
  timestamp has no lossless seconds representation.
- `title.sizeBytes`: on DVD this derives from PGC cell sector arithmetic, not
  from any file size, so it cannot be recomputed from the inventory.
- `clip.streamPath` and similar cross-references: flattening them into a
  hierarchy would duplicate clip records shared by multiple titles.
- `matrix256`: an optional legacy fingerprint some producers already emit.
  It is not a join key and its derivation is unspecified, but carrying it
  costs nothing and dropping it would discard data already in circulation.

## Consequences

A manifest must now carry enough file inventory to derive its content hash, so
a titles-only document is no longer valid alone.

Because the schema can only assert that a hash is *present*, conformance
recomputes every declared hash from the document's own inventory. A
well-formed but incorrect join key now fails CI.

While rebuilding fixtures, every invalid fixture was found to be failing on the
removed `capabilities` property rather than on its own defect, so the suite was
not actually testing negative durations, unsafe paths, or line-21 caption
fields. Each invalid fixture was rebuilt to be valid except for its stated
defect, and the conformance runner now asserts that the schema and case list
were actually loaded so it cannot report success without validating anything.
