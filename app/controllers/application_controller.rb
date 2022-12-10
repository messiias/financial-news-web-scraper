# frozen_string_literal: true

require 'sinatra/base'

class ApplicationController < Sinatra::Base
  not_found do
    body Oj.dump({ 'status' => 'this route does not exists!' })
  end
end
