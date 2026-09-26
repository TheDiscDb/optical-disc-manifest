# Capabilities

> Draft normative text.

Capabilities describe producer guarantees. They are not inferred solely from
which properties happen to be present.

The current discussion set is:

- `disc.identifiers`
- `disc.files.hash-inputs`
- `disc.files.complete`
- `disc.titles`
- `disc.titles.complete`
- `disc.segments`
- `disc.streams.declared`
- `disc.streams.payload-verified`
- `disc.chapters.counts`
- `disc.chapters.timing`
- `disc.titles.stereoscopic-3d`
- `disc.clips`

`disc.streams.declared` means that stream metadata was read from disc control
files such as DVD IFO, Blu-ray MPLS, or CLPI. `disc.streams.payload-verified`
is a separate, stronger claim that stream evidence was checked in media
payload. Declared stream evidence alone never implies payload verification.

`disc.titles.stereoscopic-3d` indicates that title evidence includes an
authored base-view/dependent-view relationship; it does not mean the dependent
view is an alternate angle or an independent title. `disc.clips` indicates
that standalone clip evidence is present. Producers only claim capabilities
they actually provide; absent or unsupported data must not be fabricated.

A producer may be complete for IFO/MPLS/CLPI structure without claiming it
inspected encrypted VOB/M2TS/SSIF payloads.
