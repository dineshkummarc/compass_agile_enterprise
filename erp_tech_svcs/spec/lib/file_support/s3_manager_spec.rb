require 'spec_helper'

describe ErpTechSvcs::FileSupport::S3Manager do

  before(:all) do
    ErpTechSvcs::FileSupport::S3Manager.setup_connection
    @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => :s3)
  end

  it "should have a root of nothing" do
    @file_support.root.should eq ''
  end

  it "should allow you to CRUD file / folder" do
    contents, message = @file_support.get_contents('not_real')
    message.should eq ErpTechSvcs::FileSupport::Manager::FILE_DOES_NOT_EXIST

    @file_support.create_file('', 'test_create_file.txt', 'test')
    @file_support.exists?('test_create_file.txt').should eq true
    contents, message = @file_support.get_contents('test_create_file.txt')
    contents.should eq 'test'

    @file_support.update_file('test_create_file.txt', 'test2')
    contents, message = @file_support.get_contents('test_create_file.txt')
    contents.should eq 'test2'

    result, message, is_directory = @file_support.delete_file('test_create_file.txt')
    result.should eq true
    is_directory.should eq false
    @file_support.exists?('test_create_file.txt').should eq false
  end

  it "should be able to build a hash tree from a path" do
    @file_support.create_folder('', 'test_folder')
    @file_support.create_file('test_folder', 'test_create_file.txt', 'test')

    path_tree_hash = @file_support.build_tree('test_folder')

    path_tree_hash[:text].should eq 'test_folder'
    path_tree_hash[:id].should eq '/test_folder'
    path_tree_hash[:leaf].should eq false
    path_tree_hash[:children].count.should eq 1

    child_path_hash = path_tree_hash[:children].first
    child_path_hash[:text].should eq 'test_create_file.txt'
    child_path_hash[:id].should eq File.join('/test_folder', 'test_create_file.txt').to_s

    result, message, is_directory = @file_support.delete_file('test_folder')
    result.should eq false
    message.should eq ErpTechSvcs::FileSupport::Manager::FOLDER_IS_NOT_EMPTY
    result, message, is_directory = @file_support.delete_file(File.join('test_folder','test_create_file.txt'))
    result.should eq true
    is_directory.should eq false
    result, message, is_directory = @file_support.delete_file('test_folder')
    result.should eq true
  end

  it "should allow you to rename a file" do
    @file_support.create_file('', 'test_create_file.txt', 'test')
    @file_support.exists?('test_create_file.txt').should eq true

    result, message = @file_support.rename_file('test_create_file.txt', 'test_rename.txt')
    result.should eq true
    @file_support.exists?('test_create_file.txt').should eq false
    @file_support.exists?('test_rename.txt').should eq true

    result, message, is_directory = @file_support.delete_file('test_rename.txt')
    @file_support.exists?('test_rename.txt').should eq false

    result, message = @file_support.rename_file('not_real.txt', 'test_rename.txt')
    result.should eq false
    message.should eq ErpTechSvcs::FileSupport::Manager::FILE_FOLDER_DOES_NOT_EXIST
  end

  it "should allow you to move a file" do
    @file_support.create_file('', 'test_create_file.txt', 'test')
    @file_support.exists?('test_create_file.txt').should eq true

    @file_support.create_folder('', 'test_folder')
    result, message = @file_support.save_move('test_create_file.txt', 'test_folder')
    result.should eq true
    @file_support.exists?(File.join('test_folder','test_create_file.txt')).should eq true

    result, message, is_directory = @file_support.delete_file(File.join('test_folder','test_create_file.txt'))
    result.should eq true
    is_directory.should eq false
    result, message, is_directory = @file_support.delete_file('test_folder')
    result.should eq true
  end


end
