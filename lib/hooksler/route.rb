module Hooksler
  class Route
    attr_reader :from
    attr_reader :to
    attr_reader :name

    def initialize(name, to, params)
      fail "TO must be OUTBOUND" unless to.class.is_a? Hooksler::Outbound

      @name = name
      @to = to
      @params = params
      @filters = [*params.delete(:filter)]
    end

    def process(message)
      return unless @to
      return unless @to.respond_to? :dump

      message = @filters.inject(message) {|a, e| e.call(a, @params) if a }

      @to.dump message if message
    end
  end
end