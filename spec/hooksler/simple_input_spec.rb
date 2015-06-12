require 'spec_helper'

describe Hooksler::SimpleInput do
  subject { Hooksler::SimpleInput.build }
  let(:request) { Struct.new(:body).new(StringIO.new("{}")) }

  it do
    should respond_to :load
  end

  it do
    expect(subject.class).to be_a Hooksler::Channel::Input
  end

  it do
    expect(Hooksler::Message).to receive(:new).with(subject.class.channel_name, {}, {})
    subject.load(request)
  end

  it do
    expect(subject.load(request)).to be_instance_of Hooksler::Message
  end

end