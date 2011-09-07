class IsoCountryCode < GeoCountry

  has_many :currencies, :through => :locales
  # TODO validate identifier is iso alphabetic two digit code

  def short_name
    name
  end
  
end
