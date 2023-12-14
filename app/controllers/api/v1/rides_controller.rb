# frozen_string_literal: true

module Api
  module V1
    # class RidesController < ApplicationController
    class RidesController < ApplicationController
      before_action :set_driver_home_address
      before_action :set_rides
      before_action :paginate_rides

      def index
        render json: {
          driver_address: @driver_home_address,
          rides: @rides.map { |ride| jsonify_ride(ride) },
          total_pages: @total_pages
        }
      end

      private

      def jsonify_ride(ride) # rubocop:disable Metrics/MethodLength
        ride_details = ride.fetch_ride(@driver_home_address)
        {
          id: ride.id,
          start_address: ride.start_address,
          destination_address: ride.destination_address,
          score: ride_details[:score],
          distance: ride_details[:ride_distance],
          duration: ride_details[:ride_duration],
          commute_distance: ride_details[:commute_distance],
          commute_duration: ride_details[:commute_duration]
        }
      end

      def set_driver_home_address
        @driver_home_address = Driver.find(params[:driver_id]).home_address
      end

      def set_rides
        @rides = Ride.all.to_a.sort_by { |ride| -ride.fetch_ride(@driver_home_address)[:score] }
      end

      def paginate_rides
        page = params[:page].to_i
        per_page = 5
        @total_pages = @rides.size / per_page
        @total_pages += 1 if @rides.size % per_page != 0
        @rides = @rides[(page - 1) * per_page, per_page]
      end
    end
  end
end
