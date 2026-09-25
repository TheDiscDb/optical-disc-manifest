# Decision 0002: Stereoscopic 3D relationships and standalone clips

- Status: accepted
- Date: 2026-02-14

## Decision

Add three new fields to the v1 schema, mirroring an implementation ahead of
this repository (`TheDiscDb/web`'s embedded copy of the schema):

- `title.stereoscopic3D` (`$defs/stereoscopicView`): represents an explicit
  Blu-ray 3D MVC base-view + dependent-view relationship. This is never an
  alternate camera angle and never a separate logical title. Fields carry
  base/dependent clip and codec/STC identity, the sync PlayItem/PTS pair used
  to align the dependent view, whether the relationship is declared via an SS
  video subpath, and dependent-stream evidence (PID/coding type/format/rate).
- `disc.clips` (`$defs/clip`): CLPI-backed standalone clip candidates, paired
  by five-character stem between `BDMV/STREAM/xxxxx.m2ts` and
  `BDMV/CLIPINF/xxxxx.clpi`. Semantically distinct from `disc.titles`: a clip
  never asserts playability. Absent CLPI or stream-file evidence is left
  unset rather than guessed.
- Two new capability flags: `disc.titles.stereoscopic-3d` and `disc.clips`.

## Known drift (out of scope for this change)

This repository's schema had already drifted from the more complete schema
embedded in `TheDiscDb/web` (for example: this repository has no root-level
`diagnostics` array, uses `disc.streams` instead of the more granular
`disc.streams.declared` / `disc.streams.payload-verified` split, and its
`stream` def lacks `pid`/`codingTypeCode`/`formatCode`/`rateCode`). This
change intentionally adds only the new fields above without reconciling that
pre-existing drift, to keep the change reviewable. A follow-up should do a
full reconciliation pass between the two schemas.

## Alternatives

- Modeling the 3D dependent view as a second logical title was rejected: it
  is not independently playable and MakeMKV/parsers do not enumerate it as a
  playlist candidate.
- Reusing `disc.titles` for clips was rejected: clips are inventory evidence,
  not playback candidates, and conflating the two would misrepresent
  authoring intent (see also MakeMKV's direct M2TS "titles", which are a
  distinct, non-authored virtual extraction concept).
