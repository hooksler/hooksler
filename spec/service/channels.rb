unless defined? TestInbound
  TestInbound = Class.new do
    def initialize(*_)
      ;
    end
  end
  TestInbound.send :extend, Hooksler::Channel::Input
  TestInbound.define_singleton_method :build do |*args|
    self.new
  end unless TestInbound.respond_to? :build

  TestInbound.define_singleton_method :route_defined do |*args|

  end unless TestInbound.respond_to? :route_defined
end

unless defined? TestOutbound
  TestOutbound = Class.new do
    def initialize(*_)

    end
  end
  TestOutbound.send :extend, Hooksler::Channel::Output
  TestOutbound.define_singleton_method :build do |*args|
    self.new
  end unless TestOutbound.respond_to? :build
end
