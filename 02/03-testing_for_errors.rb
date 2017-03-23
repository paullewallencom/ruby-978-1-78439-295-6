require 'net/http'
require 'json'
require 'timeout'

module WeatherQuery
  NetworkError = Class.new(StandardError)

  class << self
    def forecast(place)
      # check input ?
      # remove spaces ?

      JSON.parse( http(place) )
    rescue JSON::ParserError
      raise NetworkError.new("Bad response")
    end

    private

    BASE_URI = 'http://api.openweathermap.org/data/2.5/weather?q='
    def http(place)
      uri = URI(BASE_URI + place)

      Net::HTTP.get(uri)
    rescue Timeout::Error
      raise NetworkError.new("Request timed out")
    rescue URI::InvalidURIError
      raise NetworkError.new("Bad place name: #{place}")
    rescue SocketError
      raise NetworkError.new("Could not reach #{uri.to_s}")
    end
  end
end

exit unless defined?(RSpec)

describe "Misc" do
  it "raises an error" do
    expect{ 1/0 }.to raise_error
    expect{ 1/0 }.to raise_error(ZeroDivisionError)
    expect{ 1/0 }.to raise_error(ZeroDivisionError, /divided/)
    expect{ 1/0 }.to raise_error(ZeroDivisionError, "divided by 0")

    expect{ 1/0 }.to raise_error do |e|
      expect(e).to be_a(ZeroDivisionError)
      expect(e.message).to eq("divided by 0")
    end
  end

  it "does not raise an error" do
    expect{
      1/1
    }.to_not raise_error
  end

  it "raises an error" do
    expect(Net::HTTP).to receive(:get).and_raise(Timeout::Error)

    # will raise Timeout::Error
    Net::HTTP.get('http://example.org')
  end
end

describe WeatherQuery do
  describe '.forecast' do
    it "raises a NetworkError instead of Timeout::Error" do
      expect(Net::HTTP).to receive(:get).and_raise(Timeout::Error)

      expected_error   = WeatherQuery::NetworkError
      expected_message = "Request timed out"

      expect{
        WeatherQuery.forecast("Antarctica")
      }.to raise_error(expected_error, expected_message)
    end
  end
end

describe WeatherQuery do
  describe '.forecast' do
    context 'network errors' do
      let(:custom_error) { WeatherQuery::NetworkError }
      
      before do
        expect(Net::HTTP).to receive(:get)
                             .and_raise(err_to_raise)
      end

      context 'timeouts' do
        let(:err_to_raise) { Timeout::Error }
        
        it 'handles the error' do
          expect{
            WeatherQuery.forecast("Antarctica")
          }.to raise_error(custom_error, "Request timed out")          
        end
      end

      context 'invalud URI' do
        let(:err_to_raise) { URI::InvalidURIError }
        
        it 'handles the error' do
          expect{
            WeatherQuery.forecast("Antarctica")
          }.to raise_error(custom_error, "Bad place name: Antarctica")          
        end
      end        

      context 'socket errors' do
        let(:err_to_raise) { SocketError }
        
        it 'handles the error' do
          expect{
            WeatherQuery.forecast("Antarctica")
          }.to raise_error(custom_error, /Could not reach http:\/\//)          
        end
      end        
    end

    let(:xml_response) do
      %q(
        <?xml version="1.0" encoding="utf-8"?>
        <current>
          <weather number="800" value="Sky is Clear" icon="01n"/>
        </current>
      )
    end

    it "raises a NetworkError if response is not JSON" do
      expect(WeatherQuery).to receive(:http)
        .with('Antarctica')
        .and_return(xml_response)

      expect{
        WeatherQuery.forecast("Antarctica")
      }.to raise_error(
        WeatherQuery::NetworkError, "Bad response"
      )
    end
  end
end
