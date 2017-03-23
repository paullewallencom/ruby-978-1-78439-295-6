require 'jwt'

class JWTAuthMiddleware
  def initialize(app, opts={})
    if ! opts[:secret].is_a?(String)
      raise ":secret is a required option"
    end
    
    @app    = app
    @secret = opts[:secret]
  end
  
  def call(env)
    auth_header = env['HTTP_AUTHORIZATION']
  
    if ! auth_header.is_a?(String)
      raise "No auth header detected"
    end

    # header looks like: Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiYm9iIn0.sKtaCUiPRq3OWHPN6FNqC6ajyXKGGf92f_Ng488RSJc
    token = auth_header.gsub(/^Bearer /, '')
    
    # raises an error if token is invalid
    payload = JWT.decode(token, @secret)
  
    env['rack.jwt.payload'] = payload
  
    @app.call(env)    
  rescue
    puts $!.inspect
    
    [
      401,
      {},
      ["Authorization failed"]
    ]
  end
end