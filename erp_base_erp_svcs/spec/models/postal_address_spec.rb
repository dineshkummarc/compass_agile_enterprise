require 'spec_helper'

describe PostalAddress do
  it "can be instantiated" do
    PostalAddress.new.should be_an_instance_of(PostalAddress)
  end

  it "can be saved successfully" do
    PostalAddress.create.should be_persisted
  end

end