# Idnx


`idnx` provides a Ruby API for decoding Internationalized domain names into Punycode.

It provides multi-platform support by using the most approriate strategy based on the target environment:

* It uses (and requires the installation of) [libidn2](https://github.com/libidn/libidn2) in Linux / MacOS;
* It uses [the appropriate winnls APIs](https://docs.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-idntoascii) in Windows;

## Installation

If you're on Linux or Mac OS, you'll have to install `libidn2` first:

```
# Mac OS
> brew install libidn2
# Ubuntu, as an example
> apt-get install idn2
```

Add this line to your application's Gemfile:

```ruby
gem 'idnx'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install idnx

## Usage

```ruby
require "idnx"

Idnx.to_punycode("bücher.de") #=> "xn--bcher-kva.de"
```

## Development

If you want to contribute, fork this project, and submit changes via a PR on github.

For running tests, you can run `rake test`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HoneyryderChuck/idnx.
