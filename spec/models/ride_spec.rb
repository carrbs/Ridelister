# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ride, type: :model do
  it { should validate_presence_of(:start_address) }
  it { should validate_presence_of(:destination_address) }
end
