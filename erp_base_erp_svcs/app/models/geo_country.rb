class GeoCountry < ActiveRecord::Base
  has_many :postal_addresses
  has_many :geo_zones

  validates :name, :presence => {:message => 'Name cannot be blank'}
  validates :iso_code_2, :presence => {:message => 'ISO code 2 cannot be blank'}
  validates :iso_code_3, :presence => {:message => 'ISO code 3 cannot be blank'}
  
end