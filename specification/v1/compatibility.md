# Compatibility and versioning

`schemaVersion` identifies the breaking document model. A release tag identifies
the exact clarification and additive feature set.

Unsupported major versions and unknown core properties are rejected.
Namespaced extensions may be preserved or ignored according to consumer policy.
Published schema and conformance assets are immutable.

Breaking semantic changes require a new major schema version. Additive v1.x
changes require documentation, conformance cases, and compatibility review.
