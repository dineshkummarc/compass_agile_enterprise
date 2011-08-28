require 'spec_helper'

describe Note do
  it "can be instantiated" do
    Note.new.should be_an_instance_of(Note)
  end

  it "can be saved successfully" do
    Note.create.should be_persisted
  end
  
  it "can add note" do
    note = Note.create
    note.content = "test"
    note.save
    note.content.should == "test"
  end
end