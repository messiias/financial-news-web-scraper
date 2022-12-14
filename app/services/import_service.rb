# frozen_string_literal: true

class ImportService
  AVAIABLE_SOURCES = {
    'infomoney' => InfoMoneyScraper,
    'seudinheiro' => SeuDinheiroScraper
  }.freeze

  def initialize
    @logger = Logger.new($stdout)
  end

  def execute(sources:, start_date:, end_date:)
    parsed_start_date = Date.parse(start_date)
    parsed_end_date = Date.parse(end_date)
    results = []

    until parsed_start_date == parsed_end_date + 1
      result = do_scrapping(sources, parsed_start_date.to_s)
      return false if result.empty?

      results.push(*result)

      parsed_start_date += 1
    end

    return false if results.empty?

    export(results, start_date, end_date)
    true
  end

  private

  def do_scrapping(sources, date)
    results = []

    sources.each do |source|
      source_instance = AVAIABLE_SOURCES[source].new
      results.push(*source_instance.parse(date))
    end

    results
  rescue StandardError => e
    @logger.info("#{e.message}\\#{e.backtrace}")
    results
  end

  def export(results, start_date, end_date)
    file_uuid = SecureRandom.uuid
    file_path = "out/#{file_uuid} #{start_date}_#{end_date}.csv"

    CSV.open(file_path, 'w') do |csv|
      csv << %w[title text date]
      results.each { |elem| csv << elem }
    end
  end
end
