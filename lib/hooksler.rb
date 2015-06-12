require 'hooksler/version'

module Hooksler
  # Your code goes here...

  class Error < StandardError; end

  autoload :Router,  'hooksler/router'
  autoload :Route,  'hooksler/route'
  autoload :Channel,  'hooksler/channel'
  autoload :Endpoints, 'hooksler/endpoints'

  autoload :Message, 'hooksler/message' 

  autoload :Application, 'hooksler/application'
end

require 'hooksler/simple_input'

