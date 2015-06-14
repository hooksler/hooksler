require 'hooksler'

module Hooksler
  class Router

    class RouteNotFound < Hooksler::Error;
    end

    @endpoints = nil
    @channels = {input: {}, output: {}}
    VALID_TYPES = [:input, :output].freeze

    attr_reader :routes

    def self.register(type, name, klass)
      fail "Unknown type #{type} allow #{VALID_TYPES.join(', ')}" unless VALID_TYPES.include? type

      case type
        when :input
          fail 'Instance must be extended by Hooksler::Inbound' unless klass.is_a? Hooksler::Channel::Input
        when :output
          fail 'Instance must be extended by Hooksler::Outbound' unless klass.is_a? Hooksler::Channel::Output
      end

      @channels[type][name.to_sym] = klass
    end

    def self.resolve_path(*args)
      @instance.resolve_path(*args) if @instance
    end

    def self.config(&block)
      @instance ||= self.new
      @instance.instance_exec &block if block
      @instance
    end

    def self.inbounds
      @channels[:input]
    end

    def self.outbounds
      @channels[:output]
    end

    def self.info
      info = {}
      @instance.routes.each do |from, to_list|
        path = host_name + @instance.endpoints.path(from)
        info[path] = {from => to_list.map(&:name) }
      end
      info
    end

    def self.host_name(host=nil)
      if defined? @host_name
        @host_name
      else
        return ENV['HOST_NAME'] if host.nil?
        @host_name = host
      end
    end

    def host_name(host=nil)
      self.class.host_name(host)
    end

    def endpoints(&block)
      fail 'secret code not set' unless defined? @secret_code

      unless @endpoints
        @endpoints = Hooksler::Endpoints.new(@secret_code)
        @endpoints.instance_exec &block if block
      end
      @endpoints
    end

    def secret_code(code)
      if defined? @secret_code
        @secret_code
      else
        return nil if code.nil?
        @secret_code = code
      end
    end


    def route(params)
      fail 'route must be a Hash' unless params.is_a? Hash

      @routes ||= {}

      from, to = params.first

      params.delete from

      [*from].each do |i|
        fail 'from must be string or symbol' unless i.is_a?(String) || i.is_a?(Symbol)

        @routes[i.to_sym] ||= []
        @routes[i.to_sym] += [*to].map do |it|

          fail 'to must be string or symbol' unless it.is_a?(String) || it.is_a?(Symbol)
          output = @endpoints.resolve :output, it

          fail 'unknown out endpoint' unless output

          Hooksler::Route.new it, output, params
        end
      end
      @routes
    end

    def resolve_path(path)
      return if !@endpoints || path.to_s.empty?

      type, _name, key = path.split('/').select { |s| !(s.nil? || s.empty?) }

      return unless type && _name && key

      fail "unknown type #{type}" unless self.class.inbounds.key? type.to_sym
      from_instance, _type, name = @endpoints.resolve :input, key

      fail RouteNotFound.new "route for #{name} not found" unless @routes.key? name.to_sym

      [from_instance, @routes[name.to_sym]]
    rescue KeyError
      nil
    end
  end
end
