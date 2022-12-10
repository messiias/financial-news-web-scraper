# frozen_string_literal: true

require 'sinatra/base'

class ImportController < Sinatra::Base
  AVAIABLE_SOURCES = %w[infomoney seudinheiro].freeze
  HEADERS = 0
  CONTENT = 1

  post '/api/import' do
    body = Oj.load(request.body.read)

    return error params_error unless body['sources'] && body['date']
    return error sources_error unless validate_sources(body)

    seudinheiro = SeuDinheiroScraper.new
    # infomoney = InfoMoneyScraper.new

    export(seudinheiro.parse(body['date']))

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

  def export(data)
    file_uuid = SecureRandom.uuid
    file_path = "out/#{file_uuid}.csv"

    CSV.open(file_path, 'w') do |csv|
      csv << data[HEADERS]
      data[CONTENT].each { |elem| csv << elem }
    end
  end
end
