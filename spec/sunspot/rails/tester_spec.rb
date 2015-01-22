require 'spec_helper'

module Sunspot
  module Rails
    describe Tester do
      let(:tester) { described_class }

      describe '.start_original_sunspot_session' do
        let(:server) { double('sunspot_rails_server') }
        let(:pid) { 5555 }

        before do
          allow(Sunspot::Rails::Server).to receive(:new).and_return(server)
          allow(tester).to receive(:fork).and_return(pid)
          allow(tester).to receive(:kill_at_exit)
          allow(tester).to receive(:give_feedback)
        end

        after { tester.clear }

        it 'sets the "server" attribute' do
          tester.start_original_sunspot_session
          expect(tester.server).to eq(server)
        end

        it 'sets the "started" attribute' do
          tester.start_original_sunspot_session
          expect(tester.started).to be_an_instance_of(Time)
        end

        it 'sets the "pid" attribute' do
          tester.start_original_sunspot_session
          expect(tester.pid).to eq(pid)
        end
      end

      describe '.started?' do
        context 'given the "server" attribute is nil' do
          specify { expect(tester).to_not be_started }
        end

        context 'given the "server" attribute is not nil' do
          before { tester.server = :not_nil }
          specify { expect(tester).to be_started }
        end
      end

      describe '.starting' do
        let(:uri) { double('uri') }

        before do
          allow(tester).to receive(:sleep)
          allow(tester).to receive(:uri).and_return(uri)
          allow(URI).to receive(:parse).with(uri)
        end

        context 'given the "uri" is available' do
          it 'returns false' do
            expect(Net::HTTP).to receive(:get_response)
            expect(tester.starting).to be false
          end
        end

        context 'given the "uri" is not available' do
          it 'returns true' do
            expect(Net::HTTP).to receive(:get_response).and_raise(Errno::ECONNREFUSED)
            expect(tester.starting).to be true
          end
        end
      end

      describe '.seconds' do
        context 'given the "started" attribute is set to 5 seconds ago' do
          before { tester.started = Time.now - 5 }
          specify { expect(tester.seconds).to eq('5.00') }
        end
      end

      describe '.uri' do
        context 'given hostname|port|path is set to: localhost|5555|/solr' do
          let(:configuration) do
            double 'configuration', :hostname => 'localhost',
                                    :port => 5555,
                                    :path => '/solr'
          end

          before { allow(tester).to receive(:configuration).and_return(configuration) }
          specify { expect(tester.uri).to eq('http://localhost:5555/solr') }
        end
      end

      describe '.clear' do
        context 'given the "server" attribute is not nil' do
          before { tester.server = :not_nil }

          it 'sets it to nil' do
            expect(tester.server).to eq(:not_nil)
            tester.clear
            expect(tester.server).to be_nil
          end
        end
      end
    end
  end
end
