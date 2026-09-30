# Contributing

Issues and pull requests are welcome.

- **Editorial fixes:** open a pull request.
- **Normative changes** (new properties, changed meaning): open an issue first
  describing the interoperability problem. The pull request must update the
  schema and the specification together, add at least one `tests/valid` and one
  `tests/invalid` case, and pass `pwsh ./tests/Run-Tests.ps1`.
- Breaking changes require a new major `schemaVersion`.

Do not submit media payloads, decryption keys, or disc data you are not
permitted to redistribute.

## Security

Report vulnerabilities privately through GitHub's
[security advisories](../../security/advisories/new) for this repository.