require_relative 'spec_helper'
require_relative '../redis_weather_query'

describe RedisWeatherQuery, redis: true do
  subject(:weather_query) { described_class }

  after { weather_query.clear! }

  let(:json_response) { '{}' }
  before do
    allow(weather_query).to receive(:http).and_return(json_response)      
  end

  describe 'api_request is initialized' do
    it "does not raise an error" do
      weather_query.forecast('Malibu,US')
    end    
  end 

  # with around hook  
  describe 'caching' do
    let(:json_response) do
      '{"weather" : { "description" : "Sky is Clear"}}'
    end

    around(:example) do |example|
      actual = weather_query.send(:cache).all
      expect(actual).to eq({})
      
      example.run
    end

    it "stores results in local cache" do
      weather_query.forecast('Malibu,US')

      actual = weather_query.send(:cache).all
      expect(actual.keys).to eq(['Malibu,US'])
      expect(actual['Malibu,US']).to be_a(Hash)
    end

    it "uses cached result in subsequent queries" do
      weather_query.forecast('Malibu,US')
      weather_query.forecast('Malibu,US')
      weather_query.forecast('Malibu,US')
    end
  end

  # advanced state control, history
  describe 'query history' do
    before do
      expect(weather_query.history).to eq([])
    end

    it "stores every place requested" do
      places = %w(
        Malibu,US
        Beijing,CN
        Delhi,IN
        Malibu,US
        Malibu,US
        Beijing,CN
      )

      places.each {|s| weather_query.forecast(s) }

      expect(weather_query.history).to eq(places)
    end

    it "does not allow history to be modified" do
      expect {
        weather_query.history = ['Malibu,CN']
      }.to raise_error

      weather_query.history << 'Malibu,CN'
      expect(weather_query.history).to eq([])
    end
  end

  # advanced state control, api_requests
  describe 'number of API requests' do
    before do
      expect(weather_query.api_request_count).to eq(0)
    end

    it "stores every place requested" do
      places = %w(
        Malibu,US
        Beijing,CN
        Delhi,IN
        Malibu,US
        Malibu,US
        Beijing,CN
      )

      places.each {|s| weather_query.forecast(s) }

      expect(weather_query.api_request_count).to eq(3)
    end

    it "does not allow count to be modified" do
      expect {
        weather_query.api_request_count = 100
      }.to raise_error

      expect {
        weather_query.api_request_count += 10
      }.to raise_error

      expect(weather_query.api_request_count).to eq(0)
    end
  end 
end
