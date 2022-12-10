# frozen_string_literal: true

require_relative '../../../app/controllers/import_controller'
require_relative '../../../app/services/import_service'

require 'oj'

RSpec.describe ImportController, type: :controller do
  subject(:controller) { described_class.new }

  def app
    ImportController
  end

  let(:service_instance) { instance_double(ImportService) }

  let(:body) do
    {
      'sources' => %w[infomoney seudinheiro],
      'date' => '2022-02-02'
    }
  end

  let(:incomplete_body) { { 'sources' => %w[infomoney seudinheiro] } }
  let(:wrong_body) { { 'sources' => %w[random fake], 'date' => '2022-02-12' } }

  before do
    service_double = class_double(ImportService).as_stubbed_const
    allow(service_double).to receive(:new) { service_instance }
  end

  describe '#execute' do
    context 'when the method receives a request' do
      it 'must be able to receive the request and response and validate the body' do
        allow(service_instance).to receive(:execute).and_return(true)

        post '/api/import', Oj.dump(body)
        expect(Oj.load(last_response.body)).to include('status' => 'CSV Generated!')
      end

      it 'must be able to return a body with an error if a incomplete body' do
        post '/api/import', Oj.dump(incomplete_body)
        expect(Oj.load(last_response.body))
          .to include('error' => 'Missing params!')
      end

      it 'must be able to return a body with an error if a wrong body' do
        post '/api/import', Oj.dump(wrong_body)
        expect(Oj.load(last_response.body))
          .to include('error' => 'Bad request!')
      end

      it 'must be able to return a body with an error if the service fails' do
        allow(service_instance).to receive(:execute).and_return(false)

        post '/api/import', Oj.dump(body)
        # pp last_response.body
        expect(Oj.load(last_response.body))
          .to include('error' => 'Internal error!')
      end
    end
  end
end
