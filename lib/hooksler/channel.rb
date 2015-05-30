module Hooksler

  module Channel
    def build(params = {})
      self.new(params)
    end

    def register_channel(type, name)
      fail "name is #{name.class} but must be a Symbol" unless name.is_a?(Symbol)
      Hooksler::Router.register type, name, self
    end

  end

  module Inbound
    def self.extended(base)
      base.send :extend, Channel
    end

    def register(name)
      register_channel :inbound, name
    end

  end

  module Outbound
    def self.extended(base)
      base.send :extend, Channel
    end

    def register(name)
      register_channel :outbound, name
    end
  end
end
