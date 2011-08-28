require 'spec_helper'

describe GeoZone do
  it "can be instantiated" do
    GeoZone.new.should be_an_instance_of(GeoZone)
  end

  it "can be saved successfully" do
    geo_country = GeoCountry.create(:name => 'test', :iso_code_2 => '12', :iso_code_3 => '345')
    GeoZone.create(:geo_country_id => geo_country.id, :zone_code => '12', :zone_name => 'test').should be_persisted
  end
end