class DummyOutbound
  extend Hooksler::Outbound
  register :dummy

  def initialize(params)
    @params = params
  end

  def dump(message)
    puts message.message
  end
end
