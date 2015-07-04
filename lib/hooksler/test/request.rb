require 'rack/request'
require 'rack/mock'

module Hooksler
  module Test
    class Request < Rack::Request
      def self.build(data, opts = {})
        opts[:input] = data
        env = Rack::MockRequest.env_for('/', opts.merge(method: 'POST'))
        self.new env
      end
    end
  end
end

if defined? RSpec

  RSpec.shared_examples 'wrong input' do

    let(:message) { input.load request }

    it do
      expect { message }.to_not raise_error
    end

    it do
      expect( message ).to be_nil
    end
  end

  RSpec.shared_examples 'correct input' do

    let(:message) { input.load request }

    it do
      expect { message }.to_not raise_error
    end

    it do
      expect( message ).to be_instance_of Hooksler::Message
    end
  end
end
