# RFC 0001: Synchronize v1 schema with implemented evidence

- **Status:** Proposed
- **Issue:** [TheDiscDb/optical-disc-manifest#2](https://github.com/TheDiscDb/optical-disc-manifest/issues/2)
- **Scope:** Align the draft v1 schema and prose with the existing ODM producer
  model while the format remains pre-release.

## Motivation

The implementation's embedded schema includes optional evidence fields and
capabilities not yet represented by the normative repository schema. This
leaves producers and consumers with inconsistent validation rules.

## Proposal

Use the embedded v1 schema as the byte-for-byte schema source for this
synchronization. Document the added tick precision, CLPI HDR signaling,
DVD line-21 caption declarations, MVC base/dependent-view relationships,
standalone CLPI-backed clips, and diagnostics. Add conformance fixtures for
these evidence shapes and a negative fixture for invalid caption-field values.

All new evidence remains observational and conservative: control-file codes
do not claim payload verification, MVC dependent views are not angles or
separate titles, and unavailable values stay absent.

## Compatibility

The repository declares v1 pre-release with no published release. The schema
adds optional properties and capability values. No emitted manifest needs to
claim the new capabilities. The Blu-ray terminal chapter-mark sentinel policy
change is generator logic and does not alter the schema.
