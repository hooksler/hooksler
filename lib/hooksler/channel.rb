require 'hooksler'

module Hooksler

  module Channel

    def self.extended(base)
      base.send :include, InstanceMethods
    end

    def build(params = {})
      self.new(params)
    end

    def register_channel(type, name)
      fail "name is #{name.class} but must be a Symbol" unless name.is_a?(Symbol)
      @inbound_channel_name = name
      Hooksler::Router.register type, name, self
    end

    def channel_name
      @inbound_channel_name
    end

    module InstanceMethods
      def build_message(raw, params = {}, &block)
        Hooksler::Message.new(self.class.channel_name, raw, params, &block)
      end

      def route_defined(_path)

      end
    end

    module Input
      def self.extended(base)
        base.send :extend, Channel
      end

      def register(name)
        @inbound_channel_name = name
        register_channel :input, name
      end

    end

    module Output
      def self.extended(base)
        base.send :extend, Channel
      end

      def register(name)
        register_channel :output, name
      end
    end

  end


end
