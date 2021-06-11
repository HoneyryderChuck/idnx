## [Unreleased]

## [0.0.1] - 2021-06-11

This is the initial release.

### Features

`idnx` ships with a single function, which translate Innternational domain names into Punycode names, which can be used for DNS requests:

```ruby
require "idnx"

Idnx.to_punycode("bücher.de") #=> "xn--bcher-kva.de"
```

