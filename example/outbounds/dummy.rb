class DummyOutbound
  extend Hooksler::Outbound
  register :dummy

  def initialize(params)
    @params = params
  end

  def dump(message)
    puts @params.inspect
    puts message
  end
end