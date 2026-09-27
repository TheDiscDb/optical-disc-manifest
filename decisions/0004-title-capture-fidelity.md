# Decision 0004: title capture fidelity and optional file inventory

- Status: accepted
- Date: 2026-02-14
- Amends: [0003-v1-schema-simplification](0003-v1-schema-simplification.md)

## Decision

A v1 manifest must be able to carry everything a capture log already records
about a title. Two parts of decision 0003 prevented that and are reversed
here. `schemaVersion` remains 1 because nothing has been released.

### Restored

`title.chapterCount` (optional, integer, minimum 0).

0003 removed it as equal to `chapters.length`. That holds only when chapter
timings are known. A `chapter` requires `startSeconds`, so a producer that
knows a title has twelve chapters but observed no chapter boundaries has no
way to say so: it must either invent twelve timestamps or discard the count.
Capture logs report exactly this shape, and existing consumers display the
count and branch on whether it exceeds one.

When both are present, `chapters` is authoritative and `chapterCount` SHOULD
equal its length.

### Added

`title.displaySize` (optional, string) records a producer's own
human-readable rendering of `sizeBytes`, such as `"25.1 GB"`.

It is presentational and non-normative. It is carried rather than recomputed
because such renderings are not reproducible byte-exactly across producers —
rounding versus truncation, unit thresholds, and float precision all differ —
so a consumer that already displays or string-matches on a producer's
rendering cannot safely regenerate it. Consumers MUST use `sizeBytes` for any
comparison, ordering, or arithmetic.

`title.label` (optional, string) records a short human- or menu-facing name
for a title, such as a BD-J title label.

It is descriptive only. Consumers MUST NOT use it as an identity or matching
key: it is producer- and disc-authored, frequently absent, and not unique.

### Changed

`disc.files` returns to optional, and keeps `minItems: 1` when present.

0003 made it required so that a files-less document would be rejected for the
omission it actually made rather than for the hash it could not derive. That
reasoning is sound for a producer reading a disc, but it also makes a whole
class of legitimate manifest unrepresentable: one reconstructed from a prior
capture log, which carries a usable content hash recorded at capture time but
never observed the inventory.

The obligation is therefore stated normatively rather than structurally: a
producer that can enumerate the disc filesystem MUST include `files`, and
SHOULD omit it only when the inventory genuinely was not observed.

## Consequences

A manifest that declares `thediscdb-content-hash` without `files` is
**asserted, not verifiable**. No consumer can recompute the hash, and a
consumer that requires verifiable provenance is entitled to reject it.

Conformance therefore distinguishes three outcomes rather than two: verified,
asserted-but-unverifiable, and mismatched. A declared hash that cannot be
recomputed is reported as unverifiable, not as a failure, and the runner
reports that count so the category cannot grow silently.

`title.displaySize` is the only field in v1 whose value a consumer cannot
independently check. It is accepted because the alternative — recomputing a
non-reproducible rendering — fails silently and produces wrong matches, while
an untrusted stored string fails visibly.
