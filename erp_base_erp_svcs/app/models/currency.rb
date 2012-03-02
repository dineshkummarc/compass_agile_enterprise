class Currency < ActiveRecord::Base
  has_many :money
  
  def symbol
    major_unit_symbol
  end
  
  def self.usd
  	# Pull the usd currency from GeoCountry
    find_by_internal_identifier("USD")
  end
  
  def self.blank
    new
  end
end
