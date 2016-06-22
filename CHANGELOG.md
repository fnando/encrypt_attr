# Changelog

## unreleased

- Ruby 2.4+ validates the IV and key size, so now we're setting the exact size. Notice that encrypted values will be the same, since ruby ignored the additional characters.

## v0.2.1

- Ignore empty strings; OpenSSL::Cipher raises exception with it.

## v0.2.0

- Allow custom encryptor per attribute.

## v0.1.0

- Initial release.
