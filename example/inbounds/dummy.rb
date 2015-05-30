class DummyInbound
  extend Hooksler::Inbound
  register :dummy

  def initialize(params)
    @params = params
  end

  def load(request)
    message = Hooksler::Message.new
    message.message = request.body.read
    message
  end
end
