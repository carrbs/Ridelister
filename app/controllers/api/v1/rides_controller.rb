# frozen_string_literal: true

module Api
  module V1
    # RidesController handles API requests for rides
    class RidesController < ApplicationController
      MAX_DEFAULT_PROXIMITY = 20
      MAX_USER_PROXIMITY = 100
      MINIMUM_TOTAL_RIDES = 15
      DEFAULT_RIDES_PER_PAGE = 5
      DEFAULT_PAGE = 1

      before_action :set_driver_home_address, :set_rides, :set_rides_per_page, :set_page, :paginate_rides,
                    only: [:index]
      def index
        render json: {
          driver_address: @driver_home_address,
          rides: @rides.map { |ride| jsonify_ride(ride) },
          total_pages: @total_pages
        }
      end

      def ride_params
        params.permit(:driver_id, :proximity, :page, :rides_per_page)
      end

      private

      def fetch_ride_details(ride)
        ride.fetch_ride(@driver_home_address) || (raise ActiveRecord::RecordInvalid, ride)
      end

      def jsonify_ride(ride) # rubocop:disable Metrics/MethodLength
        ride_details = fetch_ride_details(ride)
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
      rescue ActiveRecord::RecordInvalid => e
        { error: e.record.errors.full_messages.join(', ') }
      end

      def set_driver_home_address
        driver_id = ride_params[:driver_id].to_i
        unless Integer(driver_id).positive?
          render json: { error: 'Invalid driver_id parameter, must be a positive integer' }, status: :bad_request
          return
        end

        @driver_home_address = Driver.find(driver_id).home_address
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Driver (ID: #{driver_id}) not found" }, status: :not_found
      end

      # TODO: Discuss breaking (or refreshing?) the caches (here and in the Ride model) when
      # the create rides functionality is implemented. Likely a simple case would be
      # using the Rails.cache.delete_matched() method.
      def set_rides # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        proximity = ride_params[:proximity]
        cache_key = "#{@driver_home_address}/#{proximity}/set_rides"
        # TODO: cache hit / miss should be a log (or be removed)
        cache_hit = Rails.cache.exist?(cache_key)
        @rides = Rails.cache.fetch(cache_key, expires_in: 1.minutes) do
          Rails.logger.info "Cache miss for #{cache_key}"
          rides = if valid_proximity?
                    Ride.near(@driver_home_address, ride_params[:proximity])
                  else
                    find_rides_near_driver
                  end
          rides.sort_by { |ride| -ride.fetch_ride(@driver_home_address)[:score] }
        end

        Rails.logger.info "Cache hit for #{cache_key}" if cache_hit
      rescue DirectionService::DirectionServiceError => e
        render json: { error: e.message }, status: :service_unavailable
      end

      def valid_proximity?
        proximity = ride_params[:proximity].to_i
        proximity.positive? && proximity <= MAX_USER_PROXIMITY
      end

      # TODO: Discuss the algorithm for finding rides near the driver. This implementation
      # focuses on finding rides within a certain proximity of the driver's home address.
      # Searching all rides in the rides table is not scalable, so we are leveraging the geocoder
      # gem to reduce the number of rides we're searching through.
      # It handles an edge case where there are very few rides near the driver's home address.
      # Depending on quantity and distribution of rides, we might consider a different approach.
      def find_rides_near_driver
        current_proximity = 1
        rides = []

        while current_proximity <= MAX_DEFAULT_PROXIMITY
          rides = Ride.near(@driver_home_address, current_proximity)
          break if rides.size >= MINIMUM_TOTAL_RIDES

          current_proximity *= 2
        end

        rides
      end

      def set_rides_per_page
        @rides_per_page = ride_params[:rides_per_page].presence&.to_i || 5
        return if @rides_per_page.positive?

        render json: { error: 'Invalid rides per_page, must be a positive integer' }, status: :bad_request
      end

      def set_page
        @current_page = ride_params[:page].presence&.to_i || 1
        return if @current_page.positive?

        render json: { error: 'Invalid page number, must be a positive integer' }, status: :bad_request
      end

      def paginate_rides
        paginated_rides = Kaminari.paginate_array(@rides).page(@current_page).per(@rides_per_page)
        @total_pages = paginated_rides.total_pages
        @rides = paginated_rides || []
      end
    end
  end
end
