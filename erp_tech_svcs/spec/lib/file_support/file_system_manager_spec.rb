require 'spec_helper'

describe ErpTechSvcs::FileSupport::FileSystemManager do

  before(:all) do
    @file_support = ErpTechSvcs::FileSupport::Base.new
  end

  it "should have a root of Rails.root" do
    @file_support.root.should eq Rails.root.to_s
  end

  it "should be able to build a hash tree from a path" do
    path_tree_hash = @file_support.build_tree(File.join(Rails.root,'lib'))

    path_tree_hash[:text].should eq 'lib'
    path_tree_hash[:id].should eq File.join(Rails.root,'lib').to_s
    path_tree_hash[:leaf].should eq false
    path_tree_hash[:children].count.should eq 1

    child_path_hash = path_tree_hash[:children].first
    child_path_hash[:text].should eq 'assets'
    child_path_hash[:id].should eq File.join(Rails.root,'lib', 'assets').to_s
  end

  it "should allow you to CRUD file / folder" do
    @file_support.create_file(Rails.root.to_s, 'test_create_file.txt', 'test')

    File.exists?(File.join(Rails.root.to_s, 'test_create_file.txt')).should eq true
    contents, message = @file_support.get_contents(File.join(Rails.root,'test_create_file.txt'))
    contents.should eq 'test'

    @file_support.update_file(File.join(Rails.root,'test_create_file.txt'), 'test2')
    contents, message = @file_support.get_contents(File.join(Rails.root,'test_create_file.txt'))
    contents.should eq 'test2'

    result, message, is_directory = @file_support.delete_file(File.join(Rails.root,'test_create_file.txt'))
    result.should eq true
    is_directory.should eq false
    File.exists?(File.join(Rails.root.to_s, 'test_create_file.txt')).should eq false
    
    @file_support.create_folder(Rails.root.to_s, 'test_folder')
    File.exists?(File.join(Rails.root,'test_folder')).should eq true

    result, message, is_directory = @file_support.delete_file(File.join(Rails.root,'test_folder'))
    result.should eq true
    is_directory.should eq true
    File.exists?(File.join(Rails.root.to_s, 'test_folder')).should eq false

    contents, message = @file_support.get_contents(File.join(Rails.root,'is_not_real.txt'))
    message.should eq ErpTechSvcs::FileSupport::Manager::FILE_DOES_NOT_EXIST

    result, message, is_directory = @file_support.delete_file(File.join(Rails.root,'not_real'))
    message.should eq ErpTechSvcs::FileSupport::Manager::FILE_FOLDER_DOES_NOT_EXIST

    result, message, is_directory = @file_support.delete_file(File.join(Rails.root,'db'))
    message.should eq ErpTechSvcs::FileSupport::Manager::FOLDER_IS_NOT_EMPTY
  end

  it "should allow you to rename a file" do
    @file_support.create_file(Rails.root.to_s, 'test_create_file.txt', 'test')
    File.exists?(File.join(Rails.root.to_s, 'test_rename.txt')).should eq false
    File.exists?(File.join(Rails.root.to_s, 'test_create_file.txt')).should eq true
    
    result, message = @file_support.rename_file(File.join(Rails.root.to_s, 'test_create_file.txt'), 'test_rename.txt')
    result.should eq true
    File.exists?(File.join(Rails.root.to_s, 'test_create_file.txt')).should eq false
    File.exists?(File.join(Rails.root.to_s, 'test_rename.txt')).should eq true

    result, message = @file_support.rename_file(File.join(Rails.root.to_s, 'not_real.txt'), 'test_rename.txt')
    result.should eq false
    message.should eq ErpTechSvcs::FileSupport::Manager::FILE_DOES_NOT_EXIST
  end

  after(:all) do
    FileUtils.rm_rf(File.join(Rails.root.to_s, 'test_create_file.txt')) if File.exists?(File.join(Rails.root.to_s, 'test_create_file.txt'))
    FileUtils.rm_rf(File.join(Rails.root.to_s, 'test_rename.txt')) if File.exists?(File.join(Rails.root.to_s, 'test_rename.txt'))
    FileUtils.rm_rf(File.join(Rails.root.to_s, 'test_folder')) if File.exists?(File.join(Rails.root.to_s, 'test_folder'))
  end


end
