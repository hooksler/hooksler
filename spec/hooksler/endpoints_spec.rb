require 'spec_helper'

describe Hooksler::Endpoints do
  subject { Hooksler::Endpoints.new('code') }

  context 'input endpoints' do
    let(:inbound) {
      unless defined? TestInbound
        TestInbound = Class.new do
          def initialize(*_); end
        end
        TestInbound.send :extend, Hooksler::Inbound
        TestInbound.define_singleton_method :build do |*args|
          self.new
        end unless TestInbound.respond_to? :build
      end
      TestInbound
    }

    before do
      Hooksler::Router.register :inbound, :test, inbound
    end

    it do
      expect(subject).to be_respond_to :input
    end

    context 'type registered' do
      it do
        expect(subject).to receive(:input).with('in_1', type: :test )
        subject.input 'in_1', type: :test
      end

      it do
        expect(inbound).to receive(:build).with({})
        expect(subject).to receive(:encode_name).with('in_1')
        expect{ subject.input 'in_1', type: :test } .to_not raise_exception
      end

      it do
        subject.input 'in_1', type: :test
        encoded_name = subject.encode_name('in_1')
        expect{ subject.resolve(:input, encoded_name) }.to_not raise_error
      end

      it do
        subject.input 'in_1', type: :test
        encoded_name = subject.encode_name('in_2')
        expect{ subject.resolve(:input, encoded_name) }.to raise_error
      end

      it do
        subject.input 'in_1', type: :test
        expect(subject.path('in_1')).to_not be_empty
      end

    end

    context 'type unknown' do
      it do
        expect(subject).to receive(:input).with('in_1', type: :test_other )
        subject.input 'in_1', type: :test_other
      end

      it do
        expect{ subject.input 'in_1', type: :test_other } .to raise_exception
      end
    end

  end

  context 'output endpoints' do
    let(:outbound) {
      unless defined? TestOutbound
        TestOutbound = Class.new do
          def initialize(*_); end
        end
        TestOutbound.send :extend, Hooksler::Outbound
        TestOutbound.define_singleton_method :build do |*args|
          self.new
        end unless TestOutbound.respond_to? :build
      end
      TestOutbound
    }

    before do
      Hooksler::Router.register :outbound, :test, outbound
    end

    it do
      expect(subject).to be_respond_to :output
    end

    context 'type registered' do
      it do
        expect(subject).to receive(:output).with('out_1', type: :test )
        subject.output 'out_1', type: :test
      end

      it do
        expect(outbound).to receive(:build).with({})
        expect{ subject.output 'out_1', type: :test } .to_not raise_exception
      end

      it do
        subject.output 'out_1', type: :test
        expect{ subject.resolve(:output, 'out_1') }.to_not raise_error
      end

      it do
        subject.output 'out_1', type: :test
        expect{ subject.resolve(:output, 'out_2') }.to raise_error
      end
    end

    context 'type unknown' do
      it do
        expect(subject).to receive(:output).with('out_1', type: :test_other )
        subject.output 'out_1', type: :test_other
      end

      it do
        expect{ subject.output 'out_1', type: :test_other } .to raise_exception
      end
    end
  end

end
