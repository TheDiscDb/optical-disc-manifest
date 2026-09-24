# Canonical JSON

> Design work required before v1.0.0.

Canonical serialization will define UTF-8 encoding, property order, array
order, Unicode normalization, number formatting, optional-property omission,
and line-ending rules. It enables deterministic bytes, stable manifest hashes,
reviewable diffs, and efficient Git deltas.

Until those rules are finalized, documents conform to the data model but do not
have a normative canonical byte representation.
