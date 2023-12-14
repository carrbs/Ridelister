# Description: Driver model
class Driver < ApplicationRecord
  validates :home_address, presence: true
  has_many :rides
end
