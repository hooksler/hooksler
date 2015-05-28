class DummyInbound
  extend Hooksler::Inbound
  register :dummy

  def initialize(params)
    @params = params
  end

  def load(request)
    request.body.read
  end
end