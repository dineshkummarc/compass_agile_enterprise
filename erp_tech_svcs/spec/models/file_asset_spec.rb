require 'spec_helper'

describe FileAsset do

  it "should allow to create a file when a file_asset is created via paperclip and the file should be removed when the model is destroyed" do
    path      = Rails.root.to_s
    name      = 'file_asset_spec_text.txt'
    base_path = File.join(path,name)
    contents  = '#Empty File'

    File.exists?(base_path).should eq false

    file_asset = FileAsset.create!(:base_path => base_path, :data => contents)

    File.exists?(base_path).should eq true
    file_data = IO.read(base_path)

    file_data.should eq contents

    file_asset.destroy
    File.exists?(base_path).should eq false
  end

  describe "class methods" do

    it "should have method to get valid extensions based on subclass" do
      TextFile.valid_extensions.should eq %w(.txt .text)
    end

    it "should have method to get all valid extensions for all subclasses" do
      FileAsset.all_valid_extensions.should eq [".jpg", ".jpeg", ".gif", ".png", ".ico", ".PNG", ".JPEG", ".JPG", ".txt", ".text", ".js", ".css", ".erb", ".haml", ".liquid", ".builder", ".html", ".pdf"]
    end

    it "should be able to lookup subclass based on extension" do
      FileAsset.type_by_extension('.txt').should eq TextFile
    end

  end

  describe "instance methods" do

    before(:all) do
      path      = Rails.root.to_s
      @name      = 'file_asset_spec_text.txt'
      @base_path = File.join(path,@name)
      contents  = '#Empty File'

      @file_asset = FileAsset.create!(:base_path => @base_path, :data => contents)
    end

    it "should have helper method to get basename" do
      @file_asset.basename.should eq 'file_asset_spec_text'
    end

    it "should have helper method to get extname" do
      @file_asset.extname.should eq 'txt'
    end

    it "should allow you to move a file" do
      new_path = File.join(Rails.root.to_s, 'move_test_tmp')

      File.exists?(@base_path).should eq true
      
      result, message = @file_asset.move(new_path)
      result.should eq true
      File.exists?(@base_path).should eq false
      File.exists?(File.join(new_path,@name)).should eq true

      FileUtils.rm_rf(new_path)
    end

    after(:all) do
      @file_asset.destroy
    end

  end
  
end