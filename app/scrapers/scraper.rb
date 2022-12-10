# frozen_string_literal: true

class Scraper
  class MethodNotImplemented < StandardError; end

  def parse
    raise MethodNotImplemented
  end

  def to_csv
    raise MethodNotImplemented
  end
end
