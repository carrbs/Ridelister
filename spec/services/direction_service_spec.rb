# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe DirectionService do
  let(:start_address) { '5405 SE Woodward St, Portland, OR 97206' }
  let(:end_address) { '3400 SE 26th Ave, Portland, OR 97202' }
  let(:direction_service) { DirectionService.new(start_address, end_address) }
  let(:valid_response_body) do
    {
      'routes' => [
        {
          'legs' => [
            {
              'distance' => { 'value' => 3131 },
              'duration' => { 'value' => 440 }
            }
          ]
        }
      ]
    }.to_json
  end

  describe '#fetch_directions' do
    context 'when the response is successful' do
      before do
        stub_request(:get, DirectionService::DIRECTIONS_URL)
          .with(query: { origin: start_address, destination: end_address, key: DirectionService::GOOGLE_API_KEY })
          .to_return(
            status: 200,
            body: valid_response_body,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      it 'returns the distance in miles and duration in minutes' do
        expect(direction_service.fetch_directions).to eq([1.9455126010000001, 0.12222222222222222])
      end
    end

    context 'when the response format is unexpected' do
      before do
        stub_request(:get, DirectionService::DIRECTIONS_URL)
          .with(query: { origin: start_address, destination: end_address, key: DirectionService::GOOGLE_API_KEY })
          .to_return(status: 200, body: '{"invalid": "format"}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises a DirectionServiceError' do
        expect do
          direction_service.fetch_directions
        end.to raise_error(DirectionService::DirectionServiceError,
                           'Unexpected response format from Google Directions API.')
      end
    end

    context 'when the response from Google Directions is unsuccessful' do
      before do
        stub_request(:get, DirectionService::DIRECTIONS_URL)
          .with(query: { origin: start_address, destination: end_address, key: DirectionService::GOOGLE_API_KEY })
          .to_return(status: 500, body: 'Internal Server Error', headers: { 'Content-Type' => 'text/plain' })
      end

      it 'raises a DirectionServiceError' do
        expect do
          direction_service.set_directions_from_google
        end.to raise_error(DirectionService::DirectionServiceError,
                           'Failed to fetch directions: 500 - Internal Server Error')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
