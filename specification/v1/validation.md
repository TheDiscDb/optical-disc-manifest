# Validation

> Draft normative text.

Consumers validate in layers:

1. Parse JSON with duplicate-property detection and bounded resources.
2. Apply the versioned JSON Schema.
3. Normalize and validate portable disc-root-relative paths.
4. Enforce semantic uniqueness relationships.
5. Apply DVD/Blu-ray/UHD plausibility rules.
6. Recompute `thediscdb-content-hash` from `disc.files` and compare it with
   the declared value.

Errors should include a stable code, JSON Pointer, and actionable message.
Consumers must not silently repair identifier mismatches or fabricate values
for unavailable evidence.
