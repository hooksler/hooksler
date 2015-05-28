module Hooksler
  class Router

    class RouteNotFound < Hooksler::Error; end

    @endpoints = nil
    @bounds = {inbound: {}, outbound: {}}
    VALID_TYPES = [:inbound, :outbound].freeze

    attr_reader :routes

    def self.register(type, name, klass)
      fail "Unknown type #{type} allow #{VALID_TYPES.join(', ')}" unless VALID_TYPES.include? type

      case type
        when :inbound
          fail 'Instance must be extended by Hooksler::Inbound' unless klass.is_a? Hooksler::Inbound
        when :outbound
          fail 'Instance must be extended by Hooksler::Outbound' unless klass.is_a? Hooksler::Outbound
      end

      @bounds[type][name.to_sym] = klass
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
      @bounds[:inbound]
    end

    def self.outbounds
      @bounds[:outbound]
    end

    def self.print
      puts ""
      puts '#' * 40
      puts '#' + 'ENDPOINTS'.center(38,' ') + '#'
      puts '#' * 40

      @instance.routes.each do |from, to_list|
        path = @instance.endpoints.path(from)
        puts "#{path}\n\t#{from} -> #{to_list.map(&:name).join(', ')}"
    end
      puts ""
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
          outbound = @endpoints.resolve :output, it

          fail 'unknown out endpoint' unless outbound

          Hooksler::Route.new it, outbound, params
        end
      end
      @routes
    end

    def resolve_path(path)
      return unless @endpoints
      type, _name, key  = path.split('/').select { |s| !(s.nil? || s.empty?) }

      fail "unknown type #{type}" unless self.class.inbounds.key? type.to_sym

      from_instance, _type, name = @endpoints.resolve :input, key

      fail RouteNotFound.new "route for #{name} not found" unless @routes.key? name.to_sym

      [ from_instance, @routes[name.to_sym] ]
    end
  end
end