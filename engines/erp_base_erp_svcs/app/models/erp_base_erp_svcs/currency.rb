class ErpBaseErpSvcs::Currency < ActiveRecord::Base

  has_morpheus :locales,
               :through => :currencies_locale,
               :models => [:iso_country_codes]
          
  has_many :money, :class_name => "ErpBaseErpSvcs::Money"
  
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
