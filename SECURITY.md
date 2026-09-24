# Security policy

Please report vulnerabilities privately through GitHub's security advisory
feature for this repository.

Optical Disc Manifest documents are untrusted input. Implementations must bound
document size, nesting, string lengths, collection counts, numeric values, and
processing time. They must reject duplicate JSON properties, unsafe paths,
duplicate semantic keys, and unsupported schema versions.

The specification does not define CSS, AACS, AACS2, or BD+ decryption and does
not permit embedded decryption keys or arbitrary media payloads.
