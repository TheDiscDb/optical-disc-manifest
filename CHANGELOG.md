# Changelog

## Unreleased

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
