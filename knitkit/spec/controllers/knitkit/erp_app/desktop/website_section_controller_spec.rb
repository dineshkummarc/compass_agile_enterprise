require "spec_helper"
require "erp_dev_svcs"

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

    it "can be a child of another section"
    
    it "should return false if save fails"
  end
end
