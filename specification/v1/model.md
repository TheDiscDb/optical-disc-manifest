# Optical Disc Manifest v1 model

> Draft normative text.

An Optical Disc Manifest is a JSON object describing observations about one
physical or imaged optical disc.

The root object contains:

- `schemaVersion`: the breaking document-model version;
- `producer`: the software that created the manifest;
- `capabilities`: observations the producer claims to provide;
- optional `capturedAt`;
- `disc`: observed disc evidence;
- optional namespaced `extensions`.

The disc object contains its format, optional name, typed identifiers, file
inventory, and ordered titles. A title uses a format-specific source:

- Blu-ray playlist;
- Blu-ray stream;
- DVD title-set/PGC/angle;
- generic file;
- explicit unknown source.

Segments, chapters, and streams are title-local. Human classification and
release metadata are outside this model.

The JSON Schema defines structural validation. The other v1 specification
documents will define semantic validation, canonical serialization,
capabilities, privacy, and compatibility before v1.0.0.
