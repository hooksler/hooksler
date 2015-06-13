require 'hooksler'
require 'multi_json'

module Hooksler
  class SimpleInput
    extend Hooksler::Channel::Input
    register :simple

    def initialize(params)
      @params = params
    end

    def load(request)
      payload = MultiJson.load(request.body.read)
      build_message(payload, payload)
    end
  end
end
