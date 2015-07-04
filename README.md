[![Code Climate](https://codeclimate.com/github/hooksler/hooksler/badges/gpa.svg)](https://codeclimate.com/github/hooksler/hooksler)
[![Test Coverage](https://codeclimate.com/github/hooksler/hooksler/badges/coverage.svg)](https://codeclimate.com/github/hooksler/hooksler/coverage)
[![Build Status](https://travis-ci.org/hooksler/hooksler.svg?branch=master)](https://travis-ci.org/hooksler/hooksler)
[![Gem Version](https://badge.fury.io/rb/hooksler.svg)](http://badge.fury.io/rb/hooksler)

# Hooksler

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
  secret_code 'very_secret_code'
  host_name 'http://example.com'

  endpoints do
    input 'simple',   type: :simple
    input 'newrelic', type: :newrelic
    input 'trello',   type: :trello,
          create: false,
          public_key:   ENV['TRELLO_KEY'],
          member_token: ENV['TRELLO_TOKEN'],
          board_id:     ENV['TRELLO_ID1']

    output 'black_hole', type: :dummy
    output 'slack_out',  type: :slack, url: ENV['SLACK_WEBHOOK_URL'], channel: '#test'
  end

  route 'simple'   => 'slack_out'
  route 'trello'   => ['black_hole', 'slack_out']
  route 'newrelic' => ['black_hole', 'slack_out']
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/hooksler/hooksler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
