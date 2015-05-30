[![Code Climate](https://codeclimate.com/github/fuCtor/hooksler/badges/gpa.svg)](https://codeclimate.com/github/fuCtor/hooksler)
[![Test Coverage](https://codeclimate.com/github/fuCtor/hooksler/badges/coverage.svg)](https://codeclimate.com/github/fuCtor/hooksler/coverage)
[![Build Status](https://travis-ci.org/fuCtor/hooksler.svg?branch=master)](https://travis-ci.org/fuCtor/hooksler)

# Hooksler

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/hooksler`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hooksler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hooksler

## Usage


routing.rb


```ruby

    Hooksler::Router.config do
      secret_key '123456789'

      endpoints do
        input 'hook_1', type: :github,   label: %i(git)
        input 'hook_2', type: :newrelic, label: %i(production)

        output 'out_1', type: :slack, url: '', channel: '#test'
        output 'out_2', type: :email, smtp: {}, to: []
      end

      route 'hook_1' => %w(out_1 out_2)
      route 'hook_2' => %w(out_1)
    end

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hooksler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
