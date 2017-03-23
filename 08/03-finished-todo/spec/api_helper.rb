ENV['RACK_ENV'] = 'test'

require_relative 'spec_helper'
require_relative '../app'
require 'rspec'
require 'rack/test'

module RackTestBrowser
  extend self

  def new_browser
    app = Todo::API
    Rack::Test::Session.new(Rack::MockSession.new(app))
  end
end