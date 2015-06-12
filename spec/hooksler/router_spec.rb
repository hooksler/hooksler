require 'spec_helper'

require 'service/channels'

describe Hooksler::Router do

  subject { Hooksler::Router.config }

  let(:inbound) { TestInbound }

  let(:outbound) { TestOutbound }

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
            expect { subject.register :input, Class.new }.to raise_exception
          end
        end

        it do
          expect(subject).to receive(:register).with(:input, 'test', inbound)
          subject.register :input, 'test', inbound
        end

        it do
          expect { subject.register :input, 'test', inbound }.to_not raise_exception
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
            expect { subject.register :output, Class.new }.to raise_exception
          end
        end

        it do
          expect(subject).to receive(:register).with(:output, 'test', outbound)
          subject.register :output, 'test', outbound
        end

        it do
          expect { subject.register :output, 'test', outbound }.to_not raise_exception
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
    let(:proc) { ->(*args) {} }

    context 'init config' do
      subject { Hooksler::Router }
      it do
        expect(subject).to receive(:config).with(no_args)
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


    context 'host name' do
      it do
        should respond_to :host_name
      end

      it do
        expect(subject).to receive(:host_name).with('host') { 'host' }
        subject.host_name('host')
      end

      it do
        expect(subject.host_name('host')).to be_eql('host')
        expect(subject.host_name('other_host')).to be_eql('host')
      end
    end

    context 'endpoints' do
      subject { Hooksler::Router.new }
      it do
        should respond_to :endpoints
      end

      context 'with secret code' do

        let(:code) { 'code' }

        before do
          subject.secret_code(code)
        end

        it do
          expect(subject).to receive(:endpoints).with(no_args)
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

      context 'without secret code' do
        it do
          expect(subject).to receive(:endpoints).with(no_args)
          subject.endpoints(&proc)
        end

        it do
          expect { subject.endpoints(&proc) }.to raise_error /secret code/
        end
      end

    end

    context 'routes' do
      it do
        should respond_to :route
      end

      before do
        Hooksler::Router.register :input, :test, inbound
        Hooksler::Router.register :output, :test, outbound
        subject.secret_code 'code'

        [*from].each do |i|
          subject.endpoints.input i, type: :test
        end if defined? from

        [*to].each do |i|
          subject.endpoints.output i, type: :test
        end if defined? to
      end

      context 'print routes' do

        let (:from) { %w(from) }
        let (:to) { 'to' }

        before do
          subject.route from => to
        end

        it do
          expect(Hooksler::Router).to be_respond_to :print
        end

        it do
          expect { Hooksler::Router.print }.to_not raise_exception
        end
      end


      shared_examples 'a right route' do

        it do
          expect(subject).to receive(:route).with(from => to)
          subject.route(from => to)
        end

        it do
          expect { subject.route(from => to) }.to_not raise_exception
        end

        context 'resolve path' do
          let (:path) {
            name = [*from].first
            key = subject.endpoints.encode_name name
            "/test/#{name}/#{key}"
          }

          before do
            subject.secret_code 'code'
            subject.host_name 'host'
            subject.route(from => to)
          end

          it do
            expect { subject.resolve_path path }.to_not raise_exception
          end

          context 'wrong path' do
            it do
              expect { subject.resolve_path path + '1' }.to_not raise_exception
              expect(subject.resolve_path(path + '1')).to be_nil
            end
          end

          it do
            expect { Hooksler::Router.resolve_path path }.to_not raise_exception
          end

          it do
            expect(Hooksler::Router.resolve_path path).to be_instance_of Array
            expect(Hooksler::Router.resolve_path(path).size).to be_eql(2)
            from, route = Hooksler::Router.resolve_path path
            expect(from).to be_instance_of TestInbound
            expect(route).to be_instance_of Array
          end

          it do
            expect(Hooksler::Router.resolve_path nil).to be_nil
            expect(Hooksler::Router.resolve_path '').to be_nil
            expect(Hooksler::Router.resolve_path '/').to be_nil
          end


        end
      end

      shared_examples 'a wrong route' do
        it do
          expect(subject).to receive(:route).with(from => to)
          subject.route(from => to)
        end

        it do
          expect { subject.route(from => to) }.to raise_exception /must be string or symbol/
        end
      end

      context 'from as string' do
        let (:from) { 'from' }
        let (:to) { 'to' }
        it_behaves_like 'a right route'
      end


      context 'from as symbol' do
        let (:from) { :from }
        let (:to) { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as symbol array' do
        let (:from) { [:from] }
        let (:to) { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as string array' do
        let (:from) { %w(from) }
        let (:to) { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as string|symbol array' do
        let (:from) { ['from', :from12] }
        let (:to) { 'to' }
        it_behaves_like 'a right route'
      end

      context 'from as other type' do
        let (:from) { 1 }
        let (:to) { 'to' }
        it_behaves_like 'a wrong route'
      end

      context 'from as array of other type' do
        let (:from) { [1] }
        let (:to) { 'to' }
        it_behaves_like 'a wrong route'
      end

      context 'to as string' do
        let (:from) { 'from' }
        let (:to) { 'to' }
        it_behaves_like 'a right route'
      end

      context 'to as symbol' do
        let (:from) { 'from' }
        let (:to) { :to }
        it_behaves_like 'a right route'
      end

      context 'to as string array' do
        let (:from) { 'from' }
        let (:to) { ['to'] }
        it_behaves_like 'a right route'
      end

      context 'to as symbol array' do
        let (:from) { 'from' }
        let (:to) { [:to] }
        it_behaves_like 'a right route'
      end

      context 'to as string|symbol array' do
        let (:from) { 'from' }
        let (:to) { ['to', :to] }
        it_behaves_like 'a right route'
      end

      context 'to as other type' do
        let (:from) { 'from' }
        let (:to) { 1 }
        it_behaves_like 'a wrong route'
      end

      context 'to as array of other type' do
        let (:from) { 'from' }
        let (:to) { [1] }
        it_behaves_like 'a wrong route'
      end

    end
  end
end
