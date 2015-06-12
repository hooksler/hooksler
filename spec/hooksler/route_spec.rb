require 'spec_helper'
require 'service/channels'

describe Hooksler::Route do
  let(:output) { TestOutbound.build }
  let(:msg) { Hooksler::Message.new :test, {} }
  subject { Hooksler::Route.new 'test', output }

  it do
    should have_attr_reader :from
  end

  it do
    should have_attr_reader :to
  end

  it do
    should have_attr_reader :name
  end

  context 'create with wrong target' do
    let(:output) { TestInbound.build }
    it do
       expect { subject } .to raise_error /must be Hooksler::Channel::Output/
    end
  end

  context 'process' do
    context 'without filters' do
      context 'with message' do
        it do
          expect(output).to receive(:dump).with(msg)
          subject.process msg
        end
      end
      context 'wrong message' do
        let(:msg) { '' }
        it do
          expect(output).to_not receive(:dump).with(msg)
          expect{ subject.process msg }.to raise_error /Hooksler::Message/
        end
      end
    end

    context 'with filters' do
      subject { Hooksler::Route.new 'test', output, filter: filter }
      context 'which return nil' do
        let(:filter) { ->(msg, params) { nil } }
        it do
          expect(filter).to receive(:call).with(msg, {})
          expect(output).to_not receive(:dump).with(msg)
          subject.process msg
        end
      end

      context 'which return msg' do
        let(:filter) { ->(msg, params) { msg } }
        it do
          expect(filter).to receive(:call).with(msg, {}) { msg }
          expect(output).to receive(:dump).with(msg)
          subject.process msg
        end
      end

    end

  end

end