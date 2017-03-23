class AuthMiddleware
  def initialize(app, opts={})
    if ! opts[:secret].is_a?(String)
      raise ':secret is required'
    end
        
    @app    = app
    @secret = opts[:secret]
  end
  
  def call(env)
    if env['HTTP_AUTHORIZATION'] == @secret
      @app.call(env)
    else
      [
        401,
        {},
        ['Not authorized']
      ]
    end
  end
end