require 'yaml'

class AddIsoCodes
  
  def self.up
    GeoCountry.load_from_file(File.join(Rails.root,'/vendor/plugins/erp_base_erp_svcs/db/data_sets/geo_countries.yml'))
    GeoZone.load_from_file(File.join(Rails.root,'/vendor/plugins/erp_base_erp_svcs/db/data_sets/geo_zones.yml'))
  end
  
  def self.down
    GeoCountry.delete_all
    GeoZone.delete_all
  end

end
