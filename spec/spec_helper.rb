if ENV['TRAVIS_CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'

    add_group 'Lib', 'lib'
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hooksler'
