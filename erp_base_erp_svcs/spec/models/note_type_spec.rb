require 'spec_helper'

describe NoteType do
  it "can be instantiated" do
    NoteType.new.should be_an_instance_of(NoteType)
  end

  it "can be saved successfully" do
    NoteType.create.should be_persisted
  end
  
end