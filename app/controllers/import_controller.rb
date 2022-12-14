# frozen_string_literal: true

require 'sinatra/base'

class ImportController < Sinatra::Base
  AVAIABLE_SOURCES = %w[infomoney seudinheiro].freeze

  post '/api/import' do
    service = ImportService.new
    body = Oj.load(request.body.read)

    return error params_error unless body['sources'] && validate_dates(body)
    return error sources_error unless validate_sources(body)

    result = service.execute(
      sources: body['sources'],
      start_date: body['start_date'],
      end_date: body['end_date']
    )

    return error service_error unless result

    [200, Oj.dump({ 'status' => 'CSV Generated!' })]
  end

  private

  def validate_dates(body)
    return false unless body['start_date'] && body['end_date']

    parsed_start_date = Date.parse(body['start_date'])
    parsed_end_date = Date.parse(body['end_date'])

    return false if parsed_start_date > parsed_end_date
    return false if parsed_start_date > Date.today || parsed_end_date > Date.today

    true
  end

  def validate_sources(body)
    body['sources'].each do |source|
      return false unless AVAIABLE_SOURCES.include?(source)
    end

    true
  end

  def params_error
    [400, Oj.dump({ 'error' => 'Invalid params!' })]
  end

  def sources_error
    [400, Oj.dump({ 'error' => 'Bad request!' })]
  end

  def service_error
    [500, Oj.dump({ 'error' => 'Internal error!' })]
  end
end
