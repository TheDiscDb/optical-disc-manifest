# Changelog

## Unreleased

- Simplified the draft v1 schema (834 to 547 lines) ahead of the first release
  candidate:
  - Removed `capabilities` and `diagnostics`. Capability flags were either
    unconditionally present or inferable from the evidence itself, and
    diagnostics described producer behavior rather than disc evidence.
  - Removed redundant array `index` properties; JSON array order is the order.
  - Removed 45-kHz tick fields from titles, chapters, segments, and clips,
    keeping only `syncPresentationTimestampTicks45k`, which has no lossless
    seconds equivalent.
  - Removed `title.chapterCount`, `file.role`, `segment.filePath`, and
    `clip.sizeBytes` as derivable from data already present.
  - Collapsed the six-variant `title.source` union into one flat object.
  - Added `stream.category`, `stream.frameRate`, `stream.isInterlaced`,
    `stream.sampleRate`, and a `menu` stream type.
  - Made `disc.identifiers` required and mandated a `thediscdb-content-hash`
    entry, renaming the previous `legacy-disc-hash` kind. `matrix256` is
    retained as an optional kind.
- Documented the normative content-hash derivation in
  `specification/v1/identifiers.md` and added `tools/validate/Get-ContentHash.ps1`
  as its reference implementation.
- Conformance now recomputes every declared content hash, so a well-formed but
  incorrect join key fails CI. Each invalid fixture was also rebuilt so that it
  fails for its own stated reason rather than on an unrelated removed property.
- Synchronized the draft v1 schema with the implemented ODM evidence model,
  including stereoscopic dependent views, standalone clips, control-file HDR
  signaling, DVD line-21 caption declarations, and tick-precision timing.
- Established the Optical Disc Manifest name and repository.
- Added the initial v1 discussion schema, examples, and conformance cases.
- Added governance and the browser parser proof-of-concept plan.
- Added `title.stereoscopic3D`, `disc.clips`, and the corresponding
  `disc.titles.stereoscopic-3d` / `disc.clips` capability flags to the v1
  schema (decision 0002). Note: this repository's schema has pre-existing
  drift from the more complete schema embedded in `TheDiscDb/web`; that
  drift is documented in decision 0002 and left for a follow-up.
