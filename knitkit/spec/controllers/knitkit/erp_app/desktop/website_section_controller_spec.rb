require "spec_helper"

describe Knitkit::ErpApp::Desktop::WebsiteSectionController do

  before(:each) do 
    basic_user_auth
    @website = Factory.create(:website, :name => "Some name")
    @website.hosts << Factory.create(:website_host)
  end

  describe "POST new" do

    it "should create a new website section" do
      post :section, {:use_route => :knitkit,
                     :action => "new",
                     :websiteId => @website.id,
                     :title => "Some New Title"}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)
    end

    it "should associate to an existing website" 
    
    it "title can not be 'blog' if section is a blog"

    it "can be a child of another section" do
      @website_section = Factory.create(:website_section)
      @website.website_sections << @website_section
      post :section, {:use_route => :knitkit,
                     :action => "new",
                     :websiteId => @website.id,
                     :title => "Some New Title",
                     :website_section_id => @website_section.id}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)
      
    end

    
    it "should fail to save if no title is given" do
      post :section, {:use_route => :knitkit,
                     :action => "new",
                     :websiteId => @website.id}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(false)
    end
  end

  describe "Post delete" do
    before(:each) do
      @website_section = Factory.create(:website_section)
      @website.website_sections << @website_section
    end

    it "should delete the given section" do
      post :section, {:use_route => :knitkit,
                     :action => "delete",
                     :id => @website_section.id}
      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)
    end
  end
  
  describe "Post update_security" do
    before(:each) do
      @website_section = Factory.create(:website_section)
      @website.website_sections << @website_section
    end
    
    it "should secure the section given secure = true" do

      @website_section_double = double("WebsiteSection")
      WebsiteSection.should_receive(:find).and_return(@website_section_double)
      @website_section_double.should_receive(:add_role)

      post :section, {:use_route => :knitkit,
                     :action => "update_security",
                     :id => @website_section.id,
                     :site_id => @website.id,
                     :secure => "true"}           
    end
    
    it "should unsecure the section given secure = false" do
      @website_section_double = double("WebsiteSection")
      WebsiteSection.should_receive(:find).and_return(@website_section_double)
      @website_section_double.should_receive(:remove_role)
      
      post :section, {:use_route => :knitkit,
                     :action => "update_security",
                     :id => @website_section.id,
                     :site_id => @website.id,
                     :secure => "false"}
    end
  end

  describe "Post update" do
    before(:each) do
      @website_section = Factory.create(:website_section)
      @website.website_sections << @website_section
    end

    it "should save" do
      post :section, {:use_route => :knitkit,
                     :action => "update",
                     :id => @website_section.id,
                     :in_menu => "yes",
                     :title => "some title",
                     :internal_identifier => "some-title"}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)
    end
  end
end
