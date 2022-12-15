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
    workdays = request_workdays(start_date, end_date)
    results = []
    pp workdays
    workdays.each do |workday|
      result = do_scrapping(sources, workday)
      next if result.empty?

      results.push(*result)
    end

    return false if results.empty?

    export(results, start_date, end_date)
    true
  end

  private

  def request_workdays(start_date, end_date)
    base_url = 'https://api.informativos.io/holiday_markets/bvmvf/working_days_by_range'
    HTTParty.get("#{base_url}/#{start_date}/#{end_date}")
  end

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
