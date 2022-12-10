# frozen_string_literal: true

require 'sinatra/base'

class ImportController < Sinatra::Base
  AVAIABLE_SOURCES = %w[infomoney seudinheiro].freeze

  post '/api/import' do
    body = Oj.load(request.body.read)

    return error params_error unless body['sources'] && body['date']
    return error sources_error unless validate_sources(body)

    [200, Oj.dump({ 'status' => 'CSV Generated!' })]
  end

  private

  def validate_sources(body)
    body['sources'].each do |source|
      return false unless AVAIABLE_SOURCES.include?(source)
    end

    true
  end

  def params_error
    [400, Oj.dump({ 'error' => 'Missing params!' })]
  end

  def sources_error
    [400, Oj.dump({ 'error' => 'Bad request!' })]
  end
end
