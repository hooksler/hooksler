module Hooksler
  module Outbound
    def register(name)
      fail "name is #{name.class} but must be a Symbol" unless name.is_a?(Symbol)
      Hooksler::Router.register :outbound, name, self
    end

    def build(params = {})
      self.new(params)
    end
  end
end