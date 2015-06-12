require 'spec_helper'

describe Hooksler::Message do

  subject do
    Hooksler::Message.new :test, {}
  end

  it do
    should have_attr_accessor :user
  end

  it do
    should have_attr_accessor :title
  end

  it do
    should have_attr_accessor :message
  end

  it do
    should have_attr_accessor :level
  end

  it do
    should have_attr_accessor :params
  end

  it do
    should have_attr_accessor :url
  end

  it do
    should have_attr_reader :source
  end

  it do
    should have_attr_reader :raw
  end

  context 'load from Hash' do
    {user: 'user', title: 'title', message: 'message', level: :info, url: :url}.each do |k, v|
      it do
        msg = Hooksler::Message.new :source, {}, k => v
        expect(msg.send(k)).to be_eql v
      end
    end
  end

  context 'correct level value' do
    [:debug, :info, :warning, :error, :critical, 'info'].each do |lvl|
      it do
        expect { subject.level = lvl }.to_not raise_exception
        expect(subject.level).to be_eql(lvl.to_sym)
      end
    end
  end

  context 'wrong level value' do
    [:value, 1].each do |lvl|
      it do
        expect { subject.level=(lvl) }.to raise_error
      end
    end
  end

end
