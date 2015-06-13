require 'hooksler'
require 'hashie'

module Hooksler
  class Message

    MESSAGE_LEVEL = [ :debug, :info, :warning, :error, :critical ].freeze

    attr_accessor :user, :title, :message, :params, :level, :url
    attr_reader :raw, :source

    def initialize(source, payload, opts = {})
      @source = source
      @raw    = payload
      @level  = :info
      @message = ''
      @title  = ''

      params = Hashie::Mash.new opts

      [ :user, :title, :message, :level, :url ].each do |s|
        next unless v = params.delete(s)
        send "#{s}=", v
      end

      yield self if block_given?
    end

    def level=(val)
      fail "Wrong message level #{val}, allow #{MESSAGE_LEVEL.join(', ')} " unless MESSAGE_LEVEL.include?(val.to_sym)
      @level = val.to_sym
    end
  end
end
