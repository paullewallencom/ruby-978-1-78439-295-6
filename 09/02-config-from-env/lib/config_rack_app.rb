require 'json'

class ConfigRackApp
  def initialize(config)
    if ! config.is_a?(Hash)
      raise "Expected a Hash, got a #{config.class}"
    end
    
    @config = config
  end
  
  def call(env)
    json_body = JSON.pretty_generate(@config)
    
    [ 
      200,                                    # HTTP status code    
      {'Content-type' => 'application/json'}, # HTTP headers
      [ json_body ]                           # HTTP body
    ] 
  end
end