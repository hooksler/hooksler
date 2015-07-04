module Hooksler
  class Application
    def self.run
      self.new
    end

    def initialize
      @root = File.dirname ENV['BUNDLE_GEMFILE']

      Dir.glob(File.join(@root, 'inputs/*.rb')).each do |file|
        require file
      end
      Dir.glob(File.join(@root, 'outputs/*.rb')).each do |file|
        require file
      end

      require File.join(@root, 'config', 'routing.rb')
    end

    def call(env)
      req = Rack::Request.new(env)
      if req.path =~ /\/_endpoints_$/
        ['200', {'Content-Type' => 'application/json'}, [MultiJson.dump(Hooksler::Router.info)]]
      else
        from_instance, routes = Hooksler::Router.resolve_path req.fullpath
        return ['410', {'Content-Type' => 'text/html'}, ['Gone']] unless from_instance

        messages = [*from_instance.load(req)].compact

        routes.each do |route|
          messages.each do |message|
            route.process(message)
          end
        end

        ['200', {'Content-Type' => 'text/plain'}, ['']]
      end
    rescue => e
      puts e
      puts e.backtrace
      ['503', {'Content-Type' => 'text/html'}, [e.to_s]]
    end
  end
end
