# Capabilities

> Draft normative text.

Capabilities describe producer guarantees. They are not inferred solely from
which properties happen to be present.

The current discussion set is:

- `disc.identifiers`
- `disc.files.hash-inputs`
- `disc.files.complete`
- `disc.titles`
- `disc.titles.complete`
- `disc.segments`
- `disc.streams`
- `disc.chapters.counts`
- `disc.chapters.timing`

Before v1.0.0, stream capability must be split into declared structural
metadata and payload-verified metadata. A browser producer can be complete for
IFO/MPLS/CLPI structure without claiming it inspected encrypted VOB/M2TS
payloads.
