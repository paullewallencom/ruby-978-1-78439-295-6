require 'bundler/setup'
require 'rack/builder'

require_relative 'dummy_app'

NoBackendTodoApp = Rack::Builder.new do
  # Serve all requests to /static as static assets
  use Rack::Static, :urls => ["/static"]

  # Serve any requests to '/index.html' with '/static/index.html'
  use Rack::Static,
    :urls  =>  ["index.html"],
    :root  =>  'static',
    :index => 'index.html'
  
  map '/api/v1' do
    run DummyApp.new
  end
end

run NoBackendTodoApp