# Contributing

Issues and pull requests are welcome.

For normative changes:

1. Open an issue describing the interoperability problem.
2. Add or update a short RFC for substantive changes.
3. Update the JSON Schema and normative specification together.
4. Add at least one valid and one invalid conformance case.
5. Run `pwsh ./tools/validate/Test-Conformance.ps1`.
6. Describe producer and consumer compatibility implications.

Do not submit copyrighted media payloads, decryption keys, drive secrets, or
metadata fixtures without clear redistribution permission. Parser
implementations copied or translated from incompatible licenses are not
accepted.
