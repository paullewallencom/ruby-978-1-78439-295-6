# original version
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

# new version with shared example groups
describe WeatherQuery do
  describe '.forecast' do
    shared_examples_for "network errors" do |err_to_raise, msg|
      before do
        expect(Net::HTTP).to receive(:get)
                             .and_raise(err_to_raise)
      end

      let(:expected_error)   { WeatherQuery::NetworkError }

      it "raises a NetworkError instead of #{err_to_raise}" do
        expect{
          WeatherQuery.forecast("Antarctica")
        }.to raise_error(expected_error, msg)
      end
    end

    it_behaves_like "network errors",
      Timeout::Error,
      "Request timed out"

    it_behaves_like "network errors",
      URI::InvalidURIError
      "Bad place name: Antarctica"

    it_behaves_like "network errors",
      SocketError,
      /Could not reach http:\/\//

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