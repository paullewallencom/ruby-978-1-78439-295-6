require 'uri'
require 'json'
require_relative 'spec_helper'
require_relative '../redis_weather_query'

describe RedisWeatherQuery, redis: true do
  subject(:weather_query) { described_class }

  after { weather_query.clear! }

  context 'end-to-end tests based on real requests' do
    http_requests = begin
      here          = File.dirname(__FILE__)
      glob_pattern  = here + '/http_requests/*'
    
      Dir[glob_pattern].inject({}) do |memo, path|
        place_name = File.basename(path)
        response   = File.read(path)
      
        memo[place_name] = response
        memo
      end
    end

    before(:example) do
      WebMock.stub_request(:get, /api\.openweathermap\.org.+/).to_return do |request|
        place    = URI.decode( request.uri.query.split('=').last )
        response = http_requests[ place.force_encoding('utf-8') ]

        { :body => response }
      end
    end
  
    http_requests.each do |place, raw_response|
      it "returns the expected response for #{place}" do       
        actual    = weather_query.forecast(place)
        expected  = JSON.parse(raw_response)

        expect(actual).to eq(expected)
      end
    end
  end
end