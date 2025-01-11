class Location < ApplicationRecord
  validates :city, presence: true, uniqueness: true
  validates :country, presence: true
  
  belongs_to :user
  has_many :forecasts, dependent: :destroy
end
