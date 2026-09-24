# Privacy and security

Manifests use disc-root-relative paths and exclude local drive letters, mount
points, usernames, home directories, hostnames, drive serials, debug paths,
keys, and media payloads.

`modifiedAt` remains optional in the discussion schema and is under review
because it may be unstable, identifying, and unnecessary for verification.

Producer URIs and extension values are untrusted and must not be fetched or
rendered as active content during validation.
