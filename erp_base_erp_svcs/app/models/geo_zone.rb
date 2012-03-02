class GeoZone < ActiveRecord::Base
  belongs_to :geo_country
  has_many :postal_addresses

  validates :geo_country_id, :presence => {:message => 'Geo country id cannot be blank'}
  validates :zone_code, :presence => {:message => 'Zone code cannot be blank'}
  validates :zone_name, :presence => {:message => 'Zone name cannot be blank'}
end