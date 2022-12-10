# frozen_string_literal: true

require_relative 'scraper'

module ScraperIndexes
  DATE = 0
  MONTH = 2
end

class SeuDinheiroScraper < Scraper
  MONTH_MAPPING = {
    'janeiro' => '01',
    'fevereiro' => '02',
    'março' => '03',
    'abril' => '04',
    'maio' => '05',
    'junho' => '06',
    'julho' => '07',
    'agosto' => '08',
    'setembro' => '09',
    'outubro' => '10',
    'novembro' => '11',
    'dezembro' => '12'
  }.freeze

  attr_reader :results

  def initialize
    super()
    @agent = Mechanize.new
    @default_url = 'https://www.seudinheiro.com/empresas'

    @main_page = @agent.get(@default_url)
    @latest_news = @main_page.search('div.stream-item-container')
  end

  def parse(date)
    count = 2
    found = false
    results = []

    loop do
      urls_and_dates = get_content_urls_by_date(date)

      urls_and_dates.each do |url_and_date|
        page = @agent.get(url_and_date['url'])
        results << read_page(page, url_and_date['date'])
      end

      break if found

      found = true unless results.empty?

      @main_page = @agent.get("#{@default_url}/pagina/#{count}/")
      @latest_news = @main_page.search('div.stream-item-container')
      count += 1

      pp count
      break if count == 500
    end

    @results = results
  end

  def to_csv
    file_uuid = SecureRandom.uuid
    file_path = "out/#{file_uuid}"

    CSV.open(file_path, 'w') do |csv|
      csv << %w[title text date]
      @results.each { |elem| csv << elem }
    end
  end

  private

  def get_content_urls_by_date(date)
    results = latest_content(date)
    header_content.each { |content| results << content if content['date'] == date }
    results
  end

  def latest_content(date)
    results = []

    @latest_news.each do |news|
      link = news.search('div.feed_content_imageMobile a').map { |elem| elem['href'] }
      next unless link.first

      parsed_date = parse_date(news.search('div.feed_content_time').text.strip)
      results << { 'url' => link.first, 'date' => parsed_date } if parsed_date == date
    end

    results
  end

  def parse_date(date)
    unformatted_date = date.split(' - ').first
    splitted_date = unformatted_date.split(' ')

    year = splitted_date.last
    month = MONTH_MAPPING[splitted_date[ScraperIndexes::MONTH]]
    date = splitted_date[ScraperIndexes::DATE]

    Date.parse("#{year}-#{month}-#{date}").to_s
  end

  def read_page(page, date)
    parsed_content = []
    title = page.search('article.single h1.single__title').text.strip
    page_content = page.search('article.single div.single__body p')

    page_content.each { |content| parsed_content << content.text.strip }

    [title, parsed_content.join(''), date]
  end

  def header_content
    links = []

    links << highlighted_content
    header_news = @main_page.search('div.medium_single a.medium_single_title')
    header_news_dates = @main_page.search('div.medium_single div.medium_single_time')

    header_news.each do |content|
      url = content['href']
      header_news_dates.each do |date|
        links << { 'url' => url, 'date' => parse_date(date.text.strip) }
      end
    end

    links
  end

  def highlighted_content
    highlighted = @main_page.search('div.category_single div a.category_single_title')

    highlighted_url = highlighted.map { |elem| elem['href'] }
    highlighted_date = @main_page.search('div.category_single div.category_single_time').text.strip

    { 'url' => highlighted_url, 'date' => highlighted_date }
  end
end
