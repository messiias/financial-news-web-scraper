# frozen_string_literal: true

class ImportService
  AVAIABLE_SOURCES = {
    'infomoney' => InfoMoneyScraper,
    'seudinheiro' => SeuDinheiroScraper
  }.freeze

  def initialize
    @logger = Logger.new($stdout)
  end

  def execute(sources:, date:)
    results = []

    begin
      sources.each do |source|
        source_instance = AVAIABLE_SOURCES[source].new
        results.push(*source_instance.parse(date))
      end
    rescue StandardError => e
      @logger.info("#{e.message}\\#{e.backtrace}")
      return false
    end

    return false if results.empty?

    export(results, date)
    true
  end

  private

  def export(results, date)
    file_uuid = SecureRandom.uuid
    file_path = "out/#{file_uuid} #{date}.csv"

    CSV.open(file_path, 'w') do |csv|
      csv << %w[title text date]
      results.each { |elem| csv << elem }
    end
  end
end
