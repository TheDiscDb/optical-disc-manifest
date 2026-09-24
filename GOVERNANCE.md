# Governance

TheDiscDb maintainers steward the Optical Disc Manifest schema namespace and
publish releases.

## Changes

- Editorial corrections may use an ordinary pull request.
- New fields, capabilities, semantics, or compatibility behavior require an
  RFC under `rfcs/`.
- Accepted substantive choices receive a decision record under `decisions/`.
- Interoperability changes should be reviewed by at least one consumer
  implementer and one independent producer implementer.
- Security and privacy changes require an explicit threat-model review.
- Breaking changes require a new major `schemaVersion` and migration guidance.

Conformance fixtures are normative where JSON Schema and prose cannot fully
express a rule.

## Releases

Maintainers publish immutable semantic-version tags and release artifacts.
Pre-release tags such as `v1.0.0-rc.1` are used until producer and consumer
conformance gates pass. Assets attached to an existing release are never
replaced.
