require 'net/http'
require 'json'
require 'timeout'

module WeatherQuery
  extend self
  
  class NetworkError < StandardError
  end

  def forecast(place, use_cache=true)
    add_to_history(place)

    if use_cache
      cache[place] ||= begin
        @api_request_count += 1
        JSON.parse( http(place) )
      end
    else
      JSON.parse( http(place) )
    end
  rescue JSON::ParserError
    raise NetworkError.new("Bad response")
  end

  def api_request_count
    @api_request_count ||= 0
  end

  def history
    (@history || []).dup
  end

  def clear!
    @history           = []
    @cache             = {}
    @api_request_count = 0
  end

  private

  def add_to_history(s)
    @history ||= []
    @history << s
  end

  def cache
    @cache ||= {}
  end

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

if defined?(RSpec)

  # without hooks, broken
  # describe WeatherQuery do
  #   describe 'caching' do
  #     let(:json_response) do
  #       '{"weather" : { "description" : "Sky is Clear"}}'
  #     end
  #
  #     it "stores results in local cache" do
  #       expect(WeatherQuery).to receive(:http).
  #                               once.
  #                               and_return(json_response)
  #
  #       actual = WeatherQuery.send(:cache)
  #       expect(actual).to eq({})
  #
  #       WeatherQuery.forecast('Malibu,US')
  #
  #       actual = WeatherQuery.send(:cache)
  #       expect(actual.keys).to eq(['Malibu,US'])
  #       expect(actual['Malibu,US']).to be_a(Hash)
  #     end
  #
  #     it "uses cached result in subsequent queries" do
  #       expect(WeatherQuery).to receive(:http).
  #                               once.
  #                               and_return(json_response)
  #
  #       WeatherQuery.forecast('Malibu,US')
  #       WeatherQuery.forecast('Malibu,US')
  #       WeatherQuery.forecast('Malibu,US')
  #     end
  #   end
  # end

  # without hooks, working
  describe WeatherQuery do
    describe 'caching' do
      let(:json_response) do
        '{"weather" : { "description" : "Sky is Clear"}}'
      end

      it "stores results in local cache" do
        WeatherQuery.clear!
      
        expect(WeatherQuery).to receive(:http).
                                once.
                                and_return(json_response)

        actual = WeatherQuery.send(:cache)
        expect(actual).to eq({})

        WeatherQuery.forecast('Malibu,US')

        actual = WeatherQuery.send(:cache)
        expect(actual.keys).to eq(['Malibu,US'])
        expect(actual['Malibu,US']).to be_a(Hash)

        WeatherQuery.clear!
      end

      it "uses cached result in subsequent queries" do
        WeatherQuery.clear!
      
        expect(WeatherQuery).to receive(:http).
                                once.
                                and_return(json_response)

        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')

        WeatherQuery.clear!
      end
    end
  end

  # with hooks
  describe WeatherQuery do
    describe 'caching' do
      let(:json_response) do
        '{"weather" : { "description" : "Sky is Clear"}}'
      end

      before do
        WeatherQuery.clear!
        
        expect(WeatherQuery).to receive(:http).
                                once.
                                and_return(json_response)

        actual = WeatherQuery.send(:cache)
        expect(actual).to eq({})
      end

      after do
        WeatherQuery.clear!
      end

      it "stores results in local cache" do
        WeatherQuery.forecast('Malibu,US')

        actual = WeatherQuery.send(:cache)
        expect(actual.keys).to eq(['Malibu,US'])
        expect(actual['Malibu,US']).to be_a(Hash)
      end

      it "uses cached result in subsequent queries" do
        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')
      end

      context "skip cache" do
        before do
          expect(WeatherQuery).to receive(:http).
                                  with('Beijing,CN').
                                  and_return(json_response)

          expect(WeatherQuery).to receive(:http).
                                  with('Delhi,IN').
                                  and_return(json_response)
        end

        it "hits API when false passed as second argument" do
          WeatherQuery.forecast('Malibu,US') # uses cache
          WeatherQuery.forecast('Beijing,CN', false)
          WeatherQuery.forecast('Delhi,IN', false)

          actual = WeatherQuery.send(:cache).keys
          expect(actual).to eq(['Malibu,US'])
        end
      end
    end
  end


  # with around hook
  describe WeatherQuery do
    describe 'caching' do
      let(:json_response) do
        '{"weather" : { "description" : "Sky is Clear"}}'
      end

      around(:example) do |example|
        actual = WeatherQuery.send(:cache)
        expect(actual).to eq({})

        example.run

        WeatherQuery.clear!
      end

      it "stores results in local cache" do
        WeatherQuery.forecast('Malibu,US')

        actual = WeatherQuery.send(:cache)
        expect(actual.keys).to eq(['Malibu,US'])
        expect(actual['Malibu,US']).to be_a(Hash)
      end

      it "uses cached result in subsequent queries" do
        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')
        WeatherQuery.forecast('Malibu,US')
      end
    end
  end


  # advanced state control, history
  describe WeatherQuery do
    describe 'query history' do
      before do
        WeatherQuery.clear!
        
        expect(WeatherQuery.history).to eq([])
        allow(WeatherQuery).to receive(:http).and_return("{}")
      end

      after do
        WeatherQuery.clear!
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

        places.each {|s| WeatherQuery.forecast(s) }

        expect(WeatherQuery.history).to eq(places)
      end

      it "does not allow history to be modified" do
        expect {
          WeatherQuery.history = ['Malibu,CN']
        }.to raise_error

        WeatherQuery.history << 'Malibu,CN'
        expect(WeatherQuery.history).to eq([])
      end
    end
  end

  # advanced state control, api_requests
  describe WeatherQuery do
    describe 'number of API requests' do
      before do
        WeatherQuery.clear!
        
        expect(WeatherQuery.api_request_count).to eq(0)
        allow(WeatherQuery).to receive(:http).and_return("{}")
      end

      after do
        WeatherQuery.clear!
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

        places.each {|s| WeatherQuery.forecast(s) }

        expect(WeatherQuery.api_request_count).to eq(3)
      end

      it "does not allow count to be modified" do
        expect {
          WeatherQuery.api_request_count = 100
        }.to raise_error

        expect {
          WeatherQuery.api_request_count += 10
        }.to raise_error

        expect(WeatherQuery.api_request_count).to eq(0)
      end
    end
  end

end
