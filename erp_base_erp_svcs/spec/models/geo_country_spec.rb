require 'spec_helper'

describe GeoCountry do
  it "can be instantiated" do
    GeoCountry.new.should be_an_instance_of(GeoCountry)
  end

  it "can be saved successfully" do
    #name, iso_code_2, :iso_code_3 are required
    GeoCountry.create(:name => 'test', :iso_code_2 => '12', :iso_code_3 => '345').should be_persisted
  end
  
end