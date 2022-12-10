# frozen_string_literal: true

require 'bundler/setup'
require 'require_all'

ENV['SINATRA_ENV'] ||= 'development'
ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default, ENV['SINATRA_ENV'])

require_all 'app'
