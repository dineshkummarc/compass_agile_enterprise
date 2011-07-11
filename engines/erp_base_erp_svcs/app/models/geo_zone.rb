class GeoZone < ActiveRecord::Base
  belongs_to :geo_country
  has_many :postal_addresses

  validates_presence_of :geo_country_id
  validates_presence_of :zone_code
  validates_presence_of :zone_name
end