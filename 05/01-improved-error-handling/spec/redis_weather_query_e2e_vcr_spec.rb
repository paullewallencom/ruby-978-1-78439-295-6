require 'uri'
require 'json'
require_relative 'spec_helper'
require_relative '../redis_weather_query'

describe RedisWeatherQuery, :vcr => {:record => VCR_RECORD_MODE}, redis: true do
  subject(:weather_query) { described_class }

  after { weather_query.clear! }

  context 'end-to-end tests based on real requests' do
    let(:actual) { weather_query.forecast(place) }

    context 'half moon bay' do
      let(:place)  { 'half moon bay' }      
      
      it 'returns a found response' do
        expect(actual).to be_a(Hash)
        expect(actual['cod']).to eq(200)
      end
    end
    
    context 'Moscow' do
      let(:place)  { 'Москва' }      
      
      it 'returns a found response' do
        expect(actual).to be_a(Hash)
        expect(actual['cod']).to eq(200)
      end
    end    
    
    context 'Beijing' do
      let(:place)  { '北京' }      
      
      it 'returns a found response' do
        expect(actual).to be_a(Hash)
        expect(actual['cod']).to eq(200)
      end
    end    
        
    context 'AJKDFH' do
      let(:place)  { 'AJKDFH' }      
      
      it 'returns a found response' do
        expect(actual).to be_a(Hash)
        expect(actual['cod']).to eq('404')
      end
    end         
  end
end