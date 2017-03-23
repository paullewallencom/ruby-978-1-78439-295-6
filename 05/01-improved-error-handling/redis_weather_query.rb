require 'net/http'
require 'json'
require 'timeout'

# require the new cache module
require_relative 'redis_weather_cache'

module RedisWeatherQuery
  extend self
  
  class NetworkError < StandardError
  end

  def forecast(place, use_cache=true)
    add_to_history(place)

    if use_cache
      cache[place] ||= begin
        increment_api_request_count
        JSON.parse( http(place) )
      end
    else
      JSON.parse( http(place) )
    end
  rescue JSON::ParserError => e
    raise NetworkError.new("Bad response: #{e.inspect}")
  end

  def increment_api_request_count
    @api_request_count ||= 0
    @api_request_count += 1
  end

  def api_request_count
    @api_request_count ||= 0
  end

  def history
    (@history || []).dup
  end

  def clear!
    @history           = []
    @api_request_count = 0
    
    # no more clearing of cache here
  end

  private

  def add_to_history(s)
    @history ||= []
    @history << s
  end

  # the new cache module has a Hash-like interface
  def cache
    RedisWeatherCache
  end

  BASE_URI = 'http://api.openweathermap.org/data/2.5/weather?q='
  def http(place)
    uri = URI( URI.escape(BASE_URI + place) )

    Net::HTTP.get(uri)
  rescue Timeout::Error
    raise NetworkError.new("Request timed out")
  rescue URI::InvalidURIError
    raise NetworkError.new("Bad place name: #{place}")
  rescue SocketError
    raise NetworkError.new("Could not reach #{uri.to_s}")
  end
end