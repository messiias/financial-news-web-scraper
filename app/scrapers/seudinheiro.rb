# frozen_string_literal: true

class SeuDinheiroScraper
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

  YEAR = 2
  DATE = 0

  def initialize
    @agent = Mechanize.new

    @main_page = @agent.get('https://www.seudinheiro.com/empresas')
    @latest_news = @main_page.search('div.stream-item-container')
  end

  def parse(date)
    result = []
    urls_and_dates = get_content_urls_by_date(date)

    urls_and_dates.each do |url_and_date|
      page = @agent.get(url_and_date['url'])
      result << read_page(page, url_and_date['date'])
    end

    [%w[title text date], result]
  end

  private

  def get_content_urls_by_date(date)
    links = []

    @latest_news.each do |news|
      link_html_path = 'div.feed_content_imageMobile a'

      link = news.search(link_html_path).map { |elem| elem['href'] }
      next unless link.first

      url = link.first
      parsed_date = parse_date(news.search('div.feed_content_time').text.strip)
      links << { 'url' => url, 'date' => parsed_date } if parsed_date == date
    end

    links
  end

  def parse_date(date)
    unformatted_date = date.split(' - ').first
    splitted_date = unformatted_date.split(' ')

    year = splitted_date.last
    month = MONTH_MAPPING[splitted_date[YEAR]]
    date = splitted_date[DATE]

    Date.parse("#{year}-#{month}-#{date}").to_s
  end

  def read_page(page, date)
    parsed_content = []
    title = page.search('article.single h1.single__title').text.strip
    page_content = page.search('article.single div.single__body p')

    page_content.each { |content| parsed_content << content.text.strip }

    [title, parsed_content.join(''), date]
  end
end
