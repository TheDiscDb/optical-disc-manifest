# Decision 0001: Optical Disc Manifest

- Status: accepted
- Date: 2026-09-24

## Decision

The formal format name is **Optical Disc Manifest**.

“Optical disc” precisely scopes DVD, Blu-ray, and UHD Blu-ray. “Manifest”
describes a portable evidence document and does not imply that one particular
scanner, application, or operating system produced it.

The repository is `TheDiscDb/optical-disc-manifest`. The suggested filename
suffix is `.odm.json`; the abbreviation is not used as the normative name.

## Alternatives

- “Media Disc” was broader but less precise and could imply non-optical media.
- “Layout” understated streams, chapters, identifiers, and provenance.
- “Contents” could imply embedded media payloads.
- “Scan” described an operation rather than the resulting stable document.
