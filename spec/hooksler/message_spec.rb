require 'spec_helper'

describe Hooksler::Message do
  it do
    should respond_to :user
  end

  it do
    should respond_to :title
  end

  it do
    should respond_to :message
  end

  it do
    should respond_to :level
  end

  it do
    should respond_to :params
  end

end
