# Optical Disc Manifest v1 model

> Draft normative text.

An Optical Disc Manifest is a JSON object describing observations about one
physical or imaged optical disc.

The root object contains:

- `schemaVersion`: the breaking document-model version;
- `producer`: the software that created the manifest;
- optional `capturedAt`;
- `disc`: observed disc evidence;
- optional namespaced `extensions`.

The disc object contains its format, optional name, required typed
identifiers, file inventory, and ordered titles.

A title locates itself with a single `source` object carrying whichever
coordinates the source format provides: `path` for a disc-relative playlist or
stream file, and `title`, `titleSet`, and `titleSetTitle` for DVD title-set
coordinates. At least one property is present. Absence of a coordinate means
it was not observed; there is no separate "unknown source" form.

Segments, chapters, and streams are title-local. Human classification and
release metadata are outside this model.

`disc.identifiers` is required and always contains a `thediscdb-content-hash`
entry. See [identifiers.md](identifiers.md) for the normative derivation.

Blu-ray MVC evidence is represented on the base playlist title using
`stereoscopic3D`. Its `relationshipType` is `3d-dependent-view`; the evidence
identifies the base and dependent clip, their codec and STC identifiers when
known, the synchronizing PlayItem and presentation timestamp when known, and
the dependent stream's authored PID and coding/format/rate codes when known.
An MVC dependent view is not an alternate camera angle and is not a separate
logical title. An SS-video subpath association may be recorded with
`isSsVideoSubPath`.

`disc.clips` describes standalone CLPI-backed Blu-ray clip evidence, separate
from title-local playlist segments. A clip may identify its M2TS path, CLPI
path, presentation duration, packet count, transport stream recording rate,
and streams declared by its CLPI. Missing values remain absent; a file
inventory size is not a payload-derived bitrate or codec profile.

Stream properties such as `dynamicRangeTypeCode`, `colorSpaceCode`, and
`hdrPlusFlag` are raw CLPI authoring/control-file evidence. They do not prove
that a payload contains a specific HDR transfer, Dolby Vision profile or
enhancement layer. DVD `line21ClosedCaptionFields` records VTS IFO flags for
caption fields 1 and/or 2; it is an authoring declaration, not proof that
caption user-data is present in VOB payload.

Durations and start offsets are expressed in seconds. The sole exception is
`syncPresentationTimestampTicks45k` in `stereoscopic3D`, which preserves the
authored 45-kHz MVC synchronization timestamp because no lossless seconds
representation exists for it. Timing values do not imply payload-level timing
verification.

The JSON Schema defines structural validation. The other v1 specification
documents will define semantic validation, canonical serialization, privacy,
and compatibility before v1.0.0.
