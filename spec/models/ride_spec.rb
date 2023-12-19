# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ride, type: :model do # rubocop:disable Metrics/BlockLength
  it { should validate_presence_of(:start_address) }
  it { should validate_presence_of(:destination_address) }

  describe '#ride_earnings' do
    let(:ride) { Ride.new }

    test_cases = [
      { name: 'distance and duration below thresholds', ride_distance: 4, ride_duration: 10, expected_earnings: 12 },
      { name: 'distance above threshold, duration below', ride_distance: 10, ride_duration: 10,
        expected_earnings: 19.5 },
      { name: 'distance below threshold, duration above', ride_distance: 4, ride_duration: 20,
        expected_earnings: 15.5 },
      { name: 'distance and duration above thresholds', ride_distance: 10, ride_duration: 20, expected_earnings: 23 }
    ]

    test_cases.each do |test_case|
      it "calculates the correct earnings for a #{test_case[:name]}" do
        earnings = ride.ride_earnings(test_case[:ride_distance], test_case[:ride_duration])
        expect(earnings).to eq(test_case[:expected_earnings])
      end
    end
  end

  describe '#fetch_ride' do # rubocop:disable Metrics/BlockLength
    let(:ride) { Ride.new(start_address: '12345 A St', destination_address: '12345 B Ave') }
    let(:drivers_home_address) { '12345 C Blvd' }

    it 'aggregates the correct ride details' do
      allow(ride).to receive(:fetch_directions).and_return([10, 20])
      allow(ride).to receive(:score).and_return(42)

      result = ride.fetch_ride(drivers_home_address)

      expected_result = {
        score: 42,
        ride_distance: 10,
        ride_duration: 20,
        commute_distance: 10,
        commute_duration: 20
      }

      expect(result).to eq(expected_result)
    end

    it 'receives a score equal to ride_earnings / 0.1 if ride_duration + commute_duration == 0' do
      allow(ride).to receive(:fetch_directions).and_return([10, 0])
      result = ride.fetch_ride(drivers_home_address)
      expected_result = {
        score: 195,
        ride_distance: 10,
        ride_duration: 0,
        commute_distance: 10,
        commute_duration: 0
      }

      expect(result).to eq(expected_result)
    end

    it 'raises a DirectionServiceError error if fetch_directions fails' do
      allow(ride).to receive(:fetch_directions).and_raise(DirectionService::DirectionServiceError)

      expect { ride.fetch_ride(drivers_home_address) }.to raise_error(DirectionService::DirectionServiceError)
    end
  end

  describe '#score' do
    let(:ride) { Ride.new }

    it 'calculates the correct score' do
      total_earnings = 50
      ride_distance = 10
      ride_duration = 20
      commute_duration = 10
      allow(ride).to receive(:ride_earnings).and_return(total_earnings)
      score = ride.send(:score, ride_distance, ride_duration, commute_duration)
      expected_score = total_earnings.to_f / (ride_duration + commute_duration)
      expect(score).to eq(expected_score.round(2))
    end
  end
end
