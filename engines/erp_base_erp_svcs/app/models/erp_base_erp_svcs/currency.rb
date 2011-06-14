class ErpBaseErpSvcs::Currency < ActiveRecord::Base

  require 'has_many_polymorphs'

  has_many_polymorphs :locales, 
    :from => [:"iso_country_codes"],
    :through => :"currencies_locale"
          
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
