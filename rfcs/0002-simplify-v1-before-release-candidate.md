# RFC 0002: Simplify v1 before the first release candidate

- Status: accepted
- Date: 2026-02-14

## Summary

Reduce the draft v1 schema to the evidence a producer can actually observe on a
disc, and make the identifier that links a manifest to a catalog entry both
required and verifiable.

## Motivation

The draft v1 schema grew by accretion while the browser and MakeMKV producers
were still being written. Three categories of accumulated weight became clear
once both producers existed:

1. **Producer process described as disc evidence.** `capabilities` and
   `diagnostics` record what a parser did, not what is on the disc. Every
   emitted manifest claimed the same capability set, so the field never
   discriminated between documents, and consumers had no decision to make
   with it. Parser failures belong in producer logs.

2. **Derivable values stored redundantly.** `title.chapterCount` duplicates
   `chapters.length`, `segment.filePath` duplicates the referenced clip's own
   path, `clip.sizeBytes` duplicates the file inventory entry, and array
   `index` properties duplicate JSON array order. Each is an opportunity for a
   document to contradict itself, and consumers must then decide which copy
   wins.

3. **Over-general shapes.** `title.source` was a six-variant `oneOf` covering
   Blu-ray playlist, Blu-ray stream, DVD PGC, DVD title, generic file, and an
   explicit unknown form. The variants shared most of their properties, and the
   discriminator forced producers to classify a source before recording what
   they observed.

Separately, `disc.identifiers` was optional, so a manifest could be structurally
valid yet impossible to associate with any disc.

## Proposal

Remove the first two categories outright. Collapse `title.source` to a single
flat object whose properties are the coordinates a source format provides, with
`minProperties: 1`; absence of a coordinate now means "not observed", which
removes the need for an explicit unknown variant.

Retain `syncPresentationTimestampTicks45k`, the one 45-kHz value with no
lossless seconds representation. Retain `title.sizeBytes`, which on DVD derives
from PGC cell sector arithmetic rather than from any file size and so is not
recoverable from the inventory.

Add the stream properties both producers already observe and could not express:
`category`, `frameRate`, `isInterlaced`, `sampleRate`, and a `menu` stream type.

Make `disc.identifiers` required and require it to contain a
`thediscdb-content-hash` entry, superseding `legacy-disc-hash` and `matrix256`.
Specify its derivation normatively and enforce it in conformance.

## Compatibility

`schemaVersion` stays at 1. No version of this format has been released, and the
repository is explicitly a pre-release draft, so there is no deployed producer
or consumer to migrate.

## Drawbacks

Requiring a content hash means a manifest must carry enough of a file inventory
to derive one. A titles-only document is no longer valid on its own. This is
intentional: such a document cannot be attached to a disc, which is the primary
purpose of the format.
