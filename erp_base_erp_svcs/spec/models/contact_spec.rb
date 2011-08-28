require 'spec_helper'

describe Contact do
  it "can be instantiated" do
    Contact.new.should be_an_instance_of(Contact)
  end

  it "can be saved successfully" do
    Contact.create.should be_persisted
  end

end