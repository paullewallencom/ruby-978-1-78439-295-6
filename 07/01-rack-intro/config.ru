require 'rack'
require_relative 'tiny_rack_app'
require_relative 'auth_middleware'

app_with_auth = Rack::Builder.new do
  if ! ENV['TINY_SECRET'].is_a?(String)
    abort 'TINY_SECRET env var must be set'
  end
  
  use AuthMiddleware, secret: ENV['TINY_SECRET']
  run TinyRackApp.new
end

run app_with_auth