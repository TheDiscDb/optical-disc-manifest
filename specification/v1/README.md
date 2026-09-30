# Optical Disc Manifest v1

> **Status: draft.** v1 may change incompatibly until `v1.0.0` is tagged.

An Optical Disc Manifest is a JSON document that records what a producer
**observed** on one DVD, Blu-ray, or UHD Blu-ray disc: its identifiers, its
file inventory, its titles, and the streams those titles declare. It does not
record editorial interpretation such as "main feature" or "episode 3".

- Schema: [`schemas/v1/optical-disc-manifest.schema.json`](../../schemas/v1/optical-disc-manifest.schema.json)
- Filename suffix: `.odm.json`
- Media type (draft): `application/vnd.thediscdb.optical-disc-manifest+json`
- Encoding: UTF-8 JSON ([RFC 8259](https://www.rfc-editor.org/rfc/rfc8259))

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are used as described
in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119). The JSON Schema defines
structure. This document defines meaning and the rules the schema cannot
express. A document conforms only if it satisfies both.

## 1. Principles

1. **Absent means not observed.** Omit a property that the producer did not
   observe. Producers MUST NOT fill in guessed, default, or placeholder
   values, and consumers MUST NOT treat absence as zero, false, or empty.
2. **Declared, not verified.** Stream properties come from navigation and
   control files (IFO, MPLS, CLPI). They say what the disc *declares*, not
   what the media payload contains. Producers do not need to decrypt or read
   VOB/M2TS payloads.
3. **Untrusted input.** Consumers MUST treat every value as untrusted and SHOULD
   recompute identifiers that can be derived (§4).

## 2. Document structure

Every object is closed: properties not listed here are invalid. Arrays are ordered. Their order is the disc's order unless
stated otherwise.

### Root

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `schemaVersion` | ✔ | `1` | Major version of this format. |
| `producer` | ✔ | object | Software that wrote the manifest. |
| `capturedAt` | | date-time | When the disc was read ([RFC 3339](https://www.rfc-editor.org/rfc/rfc3339)). |
| `disc` | ✔ | object | The disc evidence. |
| `$schema` | | URI | Optional schema hint; ignored by validation. |

### `producer`

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `name` | ✔ | string | Producer software name. |
| `version` | ✔ | string | Producer software version. |
| `uri` | | URI | Producer homepage. Consumers MUST NOT fetch it during validation. |

### `disc`

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `format` | ✔ | `dvd` \| `blu-ray` \| `uhd-blu-ray` \| `unknown` | Disc format. Use `unknown` only when the producer cannot tell. |
| `name` | | string | Volume label as read from the filesystem. |
| `identifiers` | ✔ | array of identifier | §4. |
| `files` | | array of file | Complete file inventory (§3). |
| `titles` | | array of title | Playable titles in disc order. |
| `clips` | | array of clip | Blu-ray clips described by CLPI files (§5.2). |

### `identifier`

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `kind` | ✔ | enum | See §4. |
| `value` | ✔ | string | Hex digest, with the format §4 gives for that kind. |

### `file`

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `path` | ✔ | path | Disc-relative path (§3). |
| `sizeBytes` | ✔ | integer ≥ 0 | Size reported by the filesystem. |

### `title`

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `source` | ✔ | object | Where the title is defined (below). |
| `label` | | string | Human- or menu-facing name, such as a BD-J title label. Descriptive only. MUST NOT be used as an identity or matching key. |
| `durationSeconds` | | number ≥ 0 | Playback duration. |
| `sizeBytes` | | integer ≥ 0 | Bytes of payload the title plays. On DVD this comes from cell sector ranges (×2048), so it is not a file size. |
| `displaySize` | | string | The producer's own rendering of `sizeBytes`, e.g. `"25.1 GB"`. Presentational only. Consumers MUST use `sizeBytes` for comparison or arithmetic. |
| `chapterCount` | | integer ≥ 0 | Number of chapters. Use when the count is known but chapter timings are not. If `chapters` is also present, `chapterCount` MUST equal its length. |
| `chapters` | | array of chapter | Chapter marks in order. |
| `segments` | | array of segment | The clips the title plays, in play order. |
| `streams` | | array of stream | Streams the title declares, in declaration order. |
| `stereoscopic3D` | | object | Blu-ray 3D (MVC) evidence (§5.1). |

`source` carries whichever coordinates the format provides, with at least one
property present:

| Property | Format | Meaning |
|---|---|---|
| `path` | Blu-ray | Playlist path, `BDMV/PLAYLIST/nnnnn.mpls`, or stream path, `BDMV/STREAM/nnnnn.m2ts`, for a title played directly from a clip without a playlist (common for extras). Either may be under `BDMV/BACKUP/` if read from the backup copy. |
| `title` | DVD | Title number in the VMG title search table (1–99). |
| `titleSet` | DVD | Video title set number, the *nn* in `VTS_nn_0.IFO` (1–99). |
| `titleSetTitle` | DVD | Title number within that title set (1–99). |

### `chapter`

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `startSeconds` | ✔ | number ≥ 0 | Offset of the chapter from the start of the title. |
| `durationSeconds` | | number ≥ 0 | Chapter length. |

### `segment`

A part of the disc the title plays: a Blu-ray PlayItem, or a DVD cell range.
Segments are listed in playback order, which is part of how the title is
assembled; two titles with the same duration often differ only in their
segments.

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `clip` | ✔ | string | On Blu-ray, the five-digit clip ID shared by `BDMV/CLIPINF/nnnnn.clpi` and `BDMV/STREAM/nnnnn.m2ts`. On DVD, the cell range as `first-last` (e.g. `1-19`). |
| `startSeconds` | | number ≥ 0 | Where the segment starts on the title timeline. |
| `durationSeconds` | | number ≥ 0 | Segment length. |
| `angle` | | integer ≥ 1 | Angle this segment plays for, on multi-angle titles. Omit for single-angle segments. |

### `stream`

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `type` | ✔ | `video` \| `audio` \| `subtitle` \| `menu` \| `data` \| `unknown` | Broad stream type. |
| `codec` | ✔ | string | Codec name. Use the vocabulary in §5.3. |
| `category` | | enum | Blu-ray stream-table category (`video`, `secondaryVideo`, `audio`, `secondaryAudio`, `presentationGraphics`, `interactiveGraphics`, `dolbyVisionVideo`, `pictureInPicturePresentationGraphics`) or DVD `subpicture`. It refines `type` and does not replace it. |
| `pid` | | integer 0–8191 | Transport stream PID (Blu-ray). |
| `codingTypeCode` | | integer 0–255 | Raw `stream_coding_type`. |
| `formatCode` | | integer 0–255 | Raw video format or audio presentation type code. |
| `rateCode` | | integer 0–255 | Raw frame rate or sampling frequency code. |
| `dynamicRangeTypeCode` | | integer 0–15 | Raw CLPI dynamic range type (UHD). |
| `colorSpaceCode` | | integer 0–15 | Raw CLPI color space (UHD). |
| `hdrPlusFlag` | | boolean | Raw CLPI HDR10+ flag (UHD). |
| `line21ClosedCaptionFields` | | array of `1` \| `2` | DVD VTS IFO flags declaring line-21 caption field 1 and/or 2. |
| `language` | | string | ISO 639-2 three-letter lowercase code exactly as the disc declares it (e.g. `eng`, `deu`). Map it to a locale in the consumer, not in the manifest. |
| `languageName` | | string | Producer's display name for `language`. |
| `audioLayout` | | string | Channel layout, e.g. `2.0`, `5.1`, `7.1`. |
| `sampleRate` | | integer ≥ 1 | Audio sample rate in Hz, e.g. `48000`. |
| `resolution` | | string | `WIDTHxHEIGHT` in pixels, e.g. `1920x1080`. |
| `aspectRatio` | | string | Display aspect ratio `W:H`, e.g. `16:9`. |
| `frameRate` | | number > 0 | Frames per second as a decimal, e.g. `23.976`. |
| `isInterlaced` | | boolean | Whether the video is declared interlaced. |

The `*Code` properties are the raw numeric values from the control file, kept
so consumers can decode them independently. HDR codes are declarations and do
not prove that the payload carries HDR10, HDR10+, or Dolby Vision data.
Likewise, line-21 flags do not prove that caption data is present in the VOBs.

### `clip` (Blu-ray)

| Property | Req. | Type | Meaning |
|---|---|---|---|
| `clipId` | ✔ | string | Five-digit clip ID. |
| `streamPath` | | path | Its `BDMV/STREAM/…m2ts` file. |
| `clipInfoPath` | | path | Its `BDMV/CLIPINF/…clpi` file. |
| `durationSeconds` | | number ≥ 0 | Presentation duration from the CLPI. |
| `numberOfSourcePackets` | | integer ≥ 0 | CLPI `number_of_source_packets`. |
| `transportStreamRecordingRate` | | integer ≥ 0 | CLPI `TS_recording_rate`, as stored. |
| `streams` | | array of stream | Streams the CLPI declares. |

## 3. Paths and the file inventory

A **path** is relative to the disc root. It uses `/` as the separator,
preserves the case the filesystem reports, and is NFC-normalized Unicode. It
MUST NOT start with `/` or contain `\`, empty segments, `.`, or `..`.

`disc.files`, when present:

- MUST list **every regular file** on the disc (directories, symlinks, and
  devices are excluded), with the size the filesystem reports;
- MUST NOT list the same path twice;
- MAY be in any order.

A producer that can enumerate the disc filesystem MUST include `files`. Omit
it only when the inventory was never observed, for example when rebuilding a
manifest from an older log. Without `files`, derived identifiers are
**asserted, not verifiable**. Consumers MAY reject such manifests.

## 4. Identifiers

`disc.identifiers` MUST contain exactly one `thediscdb-content-hash` and at
most one entry of each other kind.

| `kind` | Status | Value format | Derivation |
|---|---|---|---|
| `thediscdb-content-hash` | REQUIRED | 32 uppercase hex | §4.1, from `files` |
| `matrix256` | RECOMMENDED | 64 lowercase hex | §4.2, from `files` |
| `aacs-disc-id` | when present | 40 uppercase hex | SHA-1 of `AACS/Unit_Key_RO.inf` (Blu-ray) |
| `dvd-disc-id` | when present | 32 uppercase hex | libdvdread `DVDDiscID()` (MD5 of the IFO files) |

These values identify a pressing. They are not security controls.

### 4.1 `thediscdb-content-hash`

This hash is the lookup key used by [TheDiscDB](https://thediscdb.com). It
depends only on file sizes, so it is stable across tools and filesystems.

1. **Select** files, matching case-insensitively:
   - `dvd`: paths beginning with `VIDEO_TS/` and ending in `.VOB`, `.IFO`, or `.BUP`.
   - Any other format: paths beginning with `BDMV/STREAM/` and ending in `.m2ts`.
     (`.ssif` files and `BDMV/BACKUP/` are therefore excluded.)
2. **Key** each file by its bare filename, e.g. `BDMV/STREAM/00800.m2ts` → `00800.m2ts`.
3. **Sort** the keys ascending using an ordinal (byte-value) comparison.
4. **Concatenate** each file's `sizeBytes` as an 8-byte little-endian signed
   integer, in that order, with nothing between them.
5. **Hash** the result with MD5 and render it as 32 uppercase hex characters.

### 4.2 `matrix256`

[matrix256 v1](https://github.com/shitwolfymakes/matrix256/blob/main/SPEC.md)
fingerprints the whole filesystem. Computed from `disc.files`:

1. NFC-normalize each `path` and encode it as UTF-8.
2. Sort the entries by those bytes (byte-wise, like `memcmp`).
3. For each entry, emit `path` bytes, `0x00`, `sizeBytes` as base-10 ASCII
   digits, then `0x0A`.
4. Hash the result with SHA-256 and render it as 64 lowercase hex characters.

Because matrix256 covers every file, it is only correct when `files` is complete (§3).

## 5. Format-specific evidence

### 5.1 Blu-ray 3D (`stereoscopic3D`)

Put this object on the base playlist's title. An MVC dependent view is **not**
an alternate angle and **not** a separate title.

| Property | Req. | Meaning |
|---|---|---|
| `relationshipType` | ✔ | Always `3d-dependent-view`. |
| `baseClipId`, `dependentClipId` | ✔ | Clip IDs of the base and dependent views. |
| `baseCodecId`, `dependentCodecId` | | Codec identifiers from the playlist (e.g. `M2TS`). |
| `baseStcId`, `dependentStcId` | | STC sequence IDs. |
| `syncPlayItemId` | | PlayItem used to synchronize the views. |
| `syncPresentationTimestampTicks45k` | | Synchronization PTS in raw 45 kHz ticks. This is the only tick value in the format, because it has no lossless seconds form. |
| `isSsVideoSubPath` | | Whether the pairing is declared through an SS-video subpath. |
| `dependentStream` | | `{pid?, codingTypeCode, codec, formatCode?, rateCode?}` for the dependent video stream. |

### 5.2 Blu-ray clips (`disc.clips`)

`disc.clips` lists clips as their CLPI files describe them, independent of
which playlists use them. A clip is inventory evidence and does not claim to
be playable. `clipId`, `segment.clip`, and the `stereoscopic3D` clip IDs all
use the same five-digit clip IDs.

### 5.3 Codec vocabulary

Producers SHOULD use these names, matched exactly. Other names are allowed
when none of these fit.

| Type | Names |
|---|---|
| Video | `MPEG-1`, `MPEG-2`, `VC-1`, `AVC`, `MVC`, `HEVC` |
| Audio | `LPCM`, `AC-3`, `E-AC-3`, `TrueHD`, `TrueHD Atmos`, `DTS`, `DTS-ES`, `DTS-HD HRA`, `DTS-HD MA`, `DTS:X`, `MPEG Audio`, `SDDS` |
| Subtitle | `VobSub` (DVD subpicture), `PGS`, `TextST` |
| Menu | `IGS` |

## 6. Validation

Consumers SHOULD validate in this order and MUST NOT silently repair values:

1. Parse with resource limits (document size, nesting depth, string length,
   array length), rejecting duplicate object keys.
2. Validate against the JSON Schema. Reject an unsupported `schemaVersion`.
3. Check that `disc.files` paths are unique and that each `chapterCount`
   equals the length of `chapters` when both are present.
4. If `disc.files` is present, recompute `thediscdb-content-hash` and, when
   declared, `matrix256`. Reject on mismatch. If `disc.files` is absent, treat
   the declared values as asserted, not as mismatched.

The [test suite](../../tests) exercises these rules.

## 7. Privacy and security

Manifests MUST NOT contain decryption keys, media payloads, or local
environment details: drive letters, mount points, usernames, hostnames, or
drive serial numbers. Consumers MUST NOT fetch `producer.uri` or render any
value as active content.

## 8. Versioning

`schemaVersion` changes only for breaking changes. Additive v1.x releases may
add optional properties. Because objects are closed, a v1.0 consumer rejects
documents that use them, so producers SHOULD target the lowest version that
expresses their data. Published schemas are immutable.
