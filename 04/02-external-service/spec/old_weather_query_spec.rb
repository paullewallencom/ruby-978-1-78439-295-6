require_relative 'spec_helper'
require_relative '../old_weather_query'

describe OldWeatherQuery do
  subject(:weather_query) { described_class }
  
  describe 'caching' do
    let(:json_response) do
      '{"weather" : { "description" : "Sky is Clear"}}'
    end

    around(:example) do |example|
      actual = weather_query.send(:cache)
      expect(actual).to eq({})

      example.run

      weather_query.clear!
    end

    it "stores results in local cache" do
      weather_query.forecast('Malibu,US')

      actual = weather_query.send(:cache)
      expect(actual.keys).to eq(['Malibu,US'])
      expect(actual['Malibu,US']).to be_a(Hash)
    end

    it "uses cached result in subsequent queries" do
      weather_query.forecast('Malibu,US')
      weather_query.forecast('Malibu,US')
      weather_query.forecast('Malibu,US')
    end
  end

  describe 'query history' do
    before do
      expect(weather_query.history).to eq([])
      allow(weather_query).to receive(:http).and_return("{}")
    end

    after do
      weather_query.clear!
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

  describe 'number of API requests' do
    before do
      expect(weather_query.api_request_count).to eq(0)
      allow(weather_query).to receive(:http).and_return("{}")
    end

    after do
      weather_query.clear!
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
