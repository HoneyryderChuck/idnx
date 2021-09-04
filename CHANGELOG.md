## [Unreleased]

## [0.1.0] - 2021-09-04

### improvements

It ships RBS signatures for the main public API.

### compliance

`idnx` ships with a pure ruby punycode implementation (IDNA 2003), which will get loaded when `libidn2` isn't installed in the system. This was necessary for license compatibility, given that Apache 2.0 projects can rely on GPL dependencies (such as `libidn2`) but nnot exclusively.

## [0.0.1] - 2021-06-11

This is the initial release.

### Features

`idnx` ships with a single function, which translate Innternational domain names into Punycode names, which can be used for DNS requests:

```ruby
require "idnx"

Idnx.to_punycode("bücher.de") #=> "xn--bcher-kva.de"
```
