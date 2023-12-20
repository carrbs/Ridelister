# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'Api::V1::Rides', type: :request do
  let(:driver) { Driver.create!(id: 1, home_address: '123 Main St') }
  let(:ride) do
    instance_double(Ride,
                    id: 2,
                    start_address: '123 B Street, Portland, OR',
                    destination_address: '123 C Street, Portland, OR',
                    fetch_ride: { score: 1, ride_distance: 10, ride_duration: 20, commute_distance: 5,
                                  commute_duration: 10 })
  end

  let(:nearby_rides) { [ride] }

  before do
    allow(Ride).to receive(:near).and_return(nearby_rides)
  end
  describe 'GET /index' do
    context 'with valid parameters' do
      before do
        get api_v1_rides_path, params: { driver_id: driver.id, proximity: 10, page: 1, rides_per_page: 5 }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the correct driver address' do
        expect(JSON.parse(response.body)['driver_address']).to eq(driver.home_address)
      end

      it 'returns the correct number of rides' do
        expect(JSON.parse(response.body)['rides'].size).to eq(1)
      end

      context 'when requested page number is greater than total pages' do
        before do
          get api_v1_rides_path, params: { driver_id: driver.id, proximity: 10, page: 100, rides_per_page: 5 }
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'returns an empty rides array' do
          expect(JSON.parse(response.body)['rides']).to eq([])
        end
      end
    end

    context 'with invalid parameters' do
      it 'returns http bad_request for invalid driver_id' do
        get api_v1_rides_path, params: { driver_id: -1, proximity: 10, page: 1, rides_per_page: 5 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns http bad_request for invalid page' do
        get api_v1_rides_path, params: { driver_id: driver.id, proximity: 10, page: -1, rides_per_page: 5 }
        expect(response).to have_http_status(:bad_request)
      end
      it 'returns http bad_request for invalid rides_per_page' do
        get api_v1_rides_path, params: { driver_id: driver.id, proximity: 10, page: 1, rides_per_page: 'foo' }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when DirectionService::DirectionServiceError is raised' do
      before do
        allow(Ride).to receive(:near).and_raise(DirectionService::DirectionServiceError)
        get api_v1_rides_path, params: { driver_id: driver.id, proximity: 10, page: 1, rides_per_page: 5 }
      end

      it 'returns http service_unavailable' do
        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
