require 'spec_helper'

describe Hooksler::Router do

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

  context 'class' do
    subject { Hooksler::Router }
    it do
      should respond_to :register
    end

    context 'inbounds' do

      it do
        should respond_to :inbounds
      end

      context 'after register new' do
        context 'without extend' do
          it do
            expect { subject.register :inbound, Class.new }.to raise_exception
          end
        end

        it do
          expect(subject).to receive(:register).with(:inbound, 'test', inbound)
          subject.register :inbound, 'test', inbound
        end

        it do
          expect { subject.register :inbound, 'test', inbound }.to_not raise_exception
          expect(subject.inbounds).to_not be_empty
        end

        it do
          expect { inbound.register :test }.to_not raise_exception
          expect(subject.inbounds).to_not be_empty
        end

      end
    end

    context 'outbounds' do

      it do
        should respond_to :outbounds
      end

      context 'after register new' do
        context 'without extend' do
          it do
            expect { subject.register :outbound, Class.new }.to raise_exception
          end
        end

        it do
          expect(subject).to receive(:register).with(:outbound, 'test', outbound)
          subject.register :outbound, 'test', outbound
        end

        it do
          expect { subject.register :outbound, 'test', outbound }.to_not raise_exception
          expect(subject.outbounds).to_not be_empty
        end

        it do
          expect { outbound.register :test }.to_not raise_exception
          expect(subject.outbounds).to_not be_empty
        end
      end
    end

    context 'wrong type' do
      it do
        expect { subject.register :other, 'test', Class.new }.to raise_exception
      end
    end

    it do
      should respond_to :config
    end
  end

  context 'configure' do
    let(:proc) { ->() {} }

    context 'init config' do
      subject { Hooksler::Router }
      it do
        expect(subject).to receive(:config).with(&proc)
        subject.config(&proc)
      end

      it do
        expect(subject.config(&proc)).to be_instance_of Hooksler::Router
      end
    end

    context 'secret code' do
      it do
        should respond_to :secret_code
      end

      it do
        expect(subject).to receive(:secret_code).with('code')
        subject.secret_code('code')
      end

      it do
        expect(subject.secret_code('code')).to be_eql('code')
        expect(subject.secret_code('other_code')).to be_eql('code')
      end
    end

    context 'endpoints' do
      it do
        should respond_to :endpoints
      end

      context 'with secret code' do

        let(:code) { 'code' }

        before do
          subject.secret_code(code)
        end

        it do
          expect(subject).to receive(:endpoints).with(&proc)
          subject.endpoints(&proc)
        end

        it do
          expect(Hooksler::Endpoints).to receive(:new).with(code)
          expect { subject.endpoints(&proc) }.to_not raise_exception
        end

        it do
          expect(subject.endpoints(&proc)).to be_instance_of Hooksler::Endpoints
        end
      end

      context 'withot secret code' do
        it do
          expect(subject).to receive(:endpoints).with(&proc)
          subject.endpoints(&proc)
        end

        it do
          expect{ subject.endpoints(&proc) } .to raise_error /secret code/
        end
      end

    end

    context 'routes' do
      it do
        should respond_to :route
      end

      before do
        Hooksler::Router.register :inbound, :test, inbound
        Hooksler::Router.register :outbound, :test, outbound
        subject.secret_code 'code'

        [*from].each do |i|
          subject.endpoints.input i, type: :test
        end if defined? from

        [*to].each do |i|
          subject.endpoints.output i, type: :test
        end if defined? to
      end

      shared_examples 'a right route' do

        it do
          expect(subject).to receive(:route).with(from => to)
          subject.route(from => to)
        end

        it do
          expect{ subject.route(from => to) } .to_not raise_exception
        end

        context 'resolve path' do
          let (:path) {
            name = [*from].first
            key = subject.endpoints.encode_name name
            "/test/#{name}/#{key}"
          }
          it  do
            subject.secret_code 'code'
            subject.route(from => to)
            expect { subject.resolve_path path } .to_not raise_exception
          end
        end
      end

      shared_examples 'a wrong route' do
        it do
          expect(subject).to receive(:route).with(from => to)
          subject.route(from => to)
        end

        it do
          expect{ subject.route(from => to) } .to raise_exception /must be string or symbol/
        end
      end

      context 'from as string' do
        let (:from) { 'from' }
        let (:to)   { 'to' }
        it_behaves_like 'a right route'
      end


      context 'from as symbol' do
        let (:from) { :from }
        let (:to)   { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as symbol array' do
        let (:from) { %i(from) }
        let (:to)   { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as string array' do
        let (:from) { %w(from) }
        let (:to)   { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as string|symbol array' do
        let (:from) { ['from', :from12] }
        let (:to)   { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as other type' do
        let (:from) { 1 }
        let (:to)   { 'to' }
        it_behaves_like 'a wrong route'
      end

      context 'from as array of other type' do
        let (:from) { [1] }
        let (:to)   { 'to' }
        it_behaves_like 'a wrong route'
      end

      context 'to as string' do
        let (:from) { 'from' }
        let (:to)   { 'to' }
        it_behaves_like 'a right route'
      end

      context 'to as symbol' do
        let (:from) { 'from' }
        let (:to)   { :to }
        it_behaves_like 'a right route'
      end

      context 'to as string array' do
        let (:from) { 'from' }
        let (:to)   { ['to'] }
        it_behaves_like 'a right route'
      end

      context 'to as symbol array' do
        let (:from) { 'from' }
        let (:to)   { [:to] }
        it_behaves_like 'a right route'
      end

      context 'to as string|symbol array' do
        let (:from) { 'from' }
        let (:to)   { ['to', :to] }
        it_behaves_like 'a right route'
      end

      context 'to as other type' do
        let (:from) { 'from' }
        let (:to)   { 1 }
        it_behaves_like 'a wrong route'
      end

      context 'to as array of other type' do
        let (:from) { 'from' }
        let (:to)   { [1] }
        it_behaves_like 'a wrong route'
      end

    end
  end
end
