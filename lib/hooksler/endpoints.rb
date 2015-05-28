require 'digest/sha1'

module Hooksler
  class Endpoints

    def initialize(secret_code)
      @secret_code = secret_code
      @instances = {input: {}, output: {}}
    end

    def input(name, params = {})
      fail 'endpoint type must be set' unless params.key? :type

      type = params.delete(:type)
      klass = Hooksler::Router.inbounds[type.to_sym]
      fail "unknown type #{type}" unless klass

      instance = klass.build(params)

      @instances[:input][encode_name(name)] = [instance, type, name.to_s]
      instance
    end

    def output(name, params = {})
      fail 'endpoint type must be set' unless params.key? :type

      type = params.delete(:type)

      klass = Hooksler::Router.outbounds[type.to_sym]
      fail "unknown output type #{type}" unless klass
      instance = klass.build(params)

      @instances[:output][name.to_s] = instance
      instance
    end

    def path(name)
      _k, (_instance, type, in_name) = @instances[:input].detect { |_k, (_instance, type, in_name)| name.to_s == in_name }

      "/#{type}/#{in_name}/#{encode_name(in_name)}" if _k
    end

    def resolve(type, key)
      fail 'unknown type #{type}, allowed :in, :out' unless [:input, :output].include?(type)

      @instances.fetch(type).fetch(key.to_s)
    end

    def encode_name(name)
      Digest::SHA1.hexdigest "#{name}::#{@secret_code}"
    end

  end
end