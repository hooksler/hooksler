module Hooksler
  class Route
    attr_reader :from
    attr_reader :to
    attr_reader :name

    def initialize(name, to, params)
      fail "TO must be OUTBOUND" unless to.class.is_a? Hooksler::Outbound

      @name = name
      @to = to
      @filters = [*params.delete(:filter)]
      @params = params
    end

    def process(message)
      return unless @to
      return unless @to.respond_to? :dump

      message = @filters.inject(message) do |msg, filter| 
        next unless validate_message! msg
        filter.call(msg, @params)
      end
           
      @to.dump message if validate_message! message
    end

    private
    
    def validate_message!(message)
      return false unless message
      fail 'message object must be inherited from Hooksler::Message' unless message.is_a? Hooksler::Message
      true
    end

  end
end
