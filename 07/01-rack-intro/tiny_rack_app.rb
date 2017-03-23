require 'rack'

# A Rack app is any ruby object that responds to the 'call' method...
# ... in this case an instance of the TinyRackApp
class TinyRackApp
  def call(env)
    [
      200,                              # HTTP status
      {'Content-type' => 'text/plain'}, # HTTP headers
      [ "Hello", ", ", "World", "!" ]   # HTTP body, in chunks
    ]
  end
end

# if this file was executed directly, start the Rack app
if __FILE__ == $0
  Rack::Handler::WEBrick.run TinyRackApp.new
end