# RFC 0001: Browser-generated manifests

- Status: draft

## Goal

Prove that a complete structural Optical Disc Manifest can be generated in
Blazor WebAssembly from a user-selected mounted disc without MakeMKV or a native
helper.

## Phases

1. Clean-room C# DVD IFO parser with ordinary .NET and WASM fixture tests.
2. Clean-room C# MPLS/CLPI/BDMV parser with the same cross-runtime tests.
3. Browser directory enumeration, identifiers, manifest generation, schema and
   semantic validation, and local download.
4. Cross-tool comparison with MakeMKV-derived data and mkvsmith output.

## Boundaries

The proof of concept does not implement CSS/AACS/AACS2/BD+ decryption, raw
optical-device commands, ISO mounting, subprocesses, payload-scale VOB/M2TS
reads, ripping, or muxing. Declared control metadata must be distinguishable
from payload-verified metadata.

## Exit criteria

- Deterministic output in ordinary .NET and Blazor WebAssembly.
- Stable offset-aware failures for malformed fixtures.
- Representative mounted DVD, Blu-ray, and UHD scans in Chrome and Edge.
- Agreement with independent tools on shared observable facts.
- Recorded execution time and peak memory.
- No fabricated values when evidence is unavailable.
