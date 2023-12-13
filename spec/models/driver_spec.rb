# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Driver, type: :model do
  it { should validate_presence_of(:home_address) }
end
