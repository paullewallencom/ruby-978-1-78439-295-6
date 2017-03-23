require 'rack/builder'
require 'rack/parser'
require 'json'

require_relative('initializer')

map '/varz.json' do
  run TodoApp::CONFIG_RACK_APP
end