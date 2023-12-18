# frozen_string_literal: true

require 'httparty'

# DirectionsService
class DirectionService
  include HTTParty
  class DirectionServiceError < StandardError; end

  DIRECTIONS_URL = 'https://maps.googleapis.com/maps/api/directions/json'
  GOOGLE_API_KEY = ENV['GOOGLE_DIRECTIONS_API_KEY']

  def initialize(start_address, end_address)
    @start_address = start_address
    @end_address = end_address
    set_directions_from_google
  end

  # TODO: puts statements should be converted to logging statements.
  def set_directions_from_google
    puts "Fetching directions from #{@start_address} to #{@end_address}"
    @response = self.class.get(DIRECTIONS_URL,
                               query: { origin: @start_address, destination: @end_address, key: GOOGLE_API_KEY })
    return if @response.success?

    raise DirectionServiceError, "Failed to fetch directions: #{@response.code} - #{@response.message}"
  end

  def fetch_directions
    begin
      legs = @response['routes'][0]['legs'][0]
      distance = legs['distance']['value']
      duration = legs['duration']['value']
    rescue NoMethodError
      # TODO: Log the response body.
      raise DirectionServiceError, 'Unexpected response format from Google Directions API.'
    end

    distance_in_miles = distance * 0.000621371
    duration_in_minutes = duration / 60.0

    [distance_in_miles, duration_in_minutes]
  end
end
