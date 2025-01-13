class Location < ApplicationRecord
  validates :city, presence: true, uniqueness: true
  validates :country, presence: true
  
  has_many :forecasts, dependent: :destroy
end
