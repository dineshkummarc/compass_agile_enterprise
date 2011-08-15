class GeoCountry < ActiveRecord::Base
  has_many :postal_addresses
  has_many :geo_zones

  validates_presence_of :name
  validates_presence_of :iso_code_2
  validates_presence_of :iso_code_3
end