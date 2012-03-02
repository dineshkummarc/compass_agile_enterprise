require 'spec_helper'

describe Website do
  before(:all) do
    @current_user = User.create(:username => "some_user_name")
  end
  before do
    @website = Website.create(:name => "Some Site")
    @website.hosts << WebsiteHost.create(:host => "some_host")
  end

  it "can be instantiated" do
    Website.new.should be_an_instance_of(Website)
  end

  it "can be saved successfully" do
    Website.create(:name => 'Test Site').should be_persisted
  end

  describe "self.find_by_host" do
    it "should return a Website object associated to the given host" do
      
      Website.find_by_host("some_host").should eq(@website)
    end
  end

  describe "deactivate_themes!" do
    it "should set :active = false on all themes associated to the website (cant create a theme from inside test)" #do
      #@theme = Factory.create(:theme)
      #@website.themes << @theme

      #@website.themes.each do |theme|
      #  theme.active = true
      #  theme.save
      #end

      #@website.deactivate_themes!

      #@website.themes.each do |theme|
      #  theme.active.should eq(false)
      #end
    #end
  end

  describe "publish_element" do
    it "should add record to published_elements for given element" do
      comment = "some comment"
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      element = Article.create(:title => "some_article", :created_by_id => 1)
      version = 1
      
      @website.publish_element(comment, element, version, @current_user)
      @published_element = PublishedElement.find_by_published_element_record_id(element.id)
      @published_element.published_element_record_type.should eq("Content")
      @published_element.version.should eq(1)
      @published_element.published_by_id.should eq(@current_user.id)
    end
  end

  describe "publish" do
    it "should add record to published_websites for given website" do
      comment = "some comment"
      
      @website.publish(comment, @current_user)
      @published_website = PublishedWebsite.find_all_by_website_id(@website.id).last
      @published_website.published_by_id.should eq(@current_user.id)
      @published_website.comment.should eq(comment)
    end
  end

  describe "set_publication_version" do
    it "should set published_website.active to true for the given version (PublishedWebsite.activate doesnt ever save the data)" #do
      #@website.publish("some comment", @current_user)
      #@published_website = PublishedWebsite.find_by_comment("some comment")
      #version = @published_website.version
      #@test = PublishedWebsite.where('website_id = ?', @website.id).all
      #@test.should eq(version)
      #@published_website = PublishedWebsite.find_by_version_and_website_id(version, @website.id)
      #@published_website.active = false
      #@published_website.save
      #@published_website.active.should eq(false)

      #PublishedWebsite.activate(@website, version, @current_user)
      #@published_website.active.should eq(true)
    #end
  end

  describe "active_publication" do
    it "should return the active published website" do
      @active_website = @website.published_websites.find_all_by_active(true)
      @active_website.count.should eq(1)
      @website.active_publication.should eq(@active_website[0])
    end
  end

  describe "role" do
    it "should return a Role active record object with internal_identifier = website_websitename_access" do
      @website_role = @website.role
      @website_role.should be_a(Role)
      @website_role.internal_identifier.should eq("website_#{@website.name.downcase}_access")
    end
  end

  describe "setup_default_pages" do
    it "should create a section for ContactUs Search ManageProfile Login and Signup and link them to website" do
      count = 0
      @website.setup_default_pages

      @website.website_sections.each do |section|
        case
          when section.title == "Contact Us"
            count +=1 if section.website_id == @website.id
          when section.title == "Search"
            count +=1 if section.website_id == @website.id
          when section.title == "Manage Profile"
            count +=1 if section.website_id == @website.id
          when section.title == "Login"
            count +=1 if section.website_id == @website.id
          when section.title == "Sign Up"
            count +=1 if section.website_id == @website.id
          when section.title == "Reset Password"
            count +=1 if section.website_id == @website.id
        end
      end

      count.should eq(@website.website_sections.count)
    end

    it "should set all new sections as in_menu except for Login Sign Up and Reset Password" do
      @website.setup_default_pages

      @website.website_sections.each do |section|
        section.in_menu.should eq(true) unless section.title == "Login" or section.title == "Sign Up" or section.title == "Reset Password"
      end
    end

    it "should update the paths" do
      @website.setup_default_pages
      
      @website.website_sections.each do |section|
        section.path.should eq("/#{section.internal_identifier}")
      end
    end
  end
end