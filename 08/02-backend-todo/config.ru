require 'bundler/setup'
require 'rack/builder'
require 'multi_json'
require 'rack/parser'

require_relative 'app'

TodoApp = Rack::Builder.new do  
  # Serve all requests to /static as static assets
  use Rack::Static, :urls => ["/static"]

  # Serve any requests to '/index.html' with '/static/index.html'
  use Rack::Static,
    :urls  =>  ["index.html"],
    :root  =>  'static',
    :index => 'index.html'
  
  # parse JSON bodies when Content-type header is set to 'application/json'
  use Rack::Parser, :content_types => {
    'application/json'  => Proc.new { |body| ::MultiJson.decode body }
  }    
  
  map '/api/v1/todos' do
    run Todo::API
  end
end

run TodoApp