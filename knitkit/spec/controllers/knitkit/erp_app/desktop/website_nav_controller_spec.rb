require "spec_helper"
require "erp_dev_svcs"

describe Knitkit::ErpApp::Desktop::WebsiteNavController do
  before(:each) do
    basic_user_auth_with_admin
    @website = Factory.create(:website, :name => "Some name")
    @website.hosts << Factory.create(:website_host)
  end

  describe "Post new" do
    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                 :action => "new",
                 :website_id =>  @website.id,
                 :name => "new_nav_name"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

    it "should return node" do
      post :foo, {:use_route => :knitkit,
                 :action => "new",
                 :website_id => @website.id,
                 :name => "new_nav_name"}

      parsed_body = JSON.parse(response.body)
      parsed_body["node"].should include(
        {"text" => "new_nav_name", "websiteNavId" => 1, "websiteId" => @website.id,
         "iconCls" => "icon-index", "canAddMenuItems" => true, "isWebsiteNav" => true,
         "leaf" => false, "children" => []})
    end
  end

  describe "Post update" do
    before do
      @website_nav = Factory.create(:website_nav, :name => "Some Name")
      @website.website_navs << @website_nav
    end

    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                 :action => "update",
                 :website_nav_id => @website_nav.id,
                 :name => "newer_name"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true) 
    end
  end

  describe "Post delete" do
    before do
      @website_nav = Factory.create(:website_nav, :name => "Some Name")
      @website.website_navs << @website_nav
    end

    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                 :action => "delete",
                 :id => @website_nav.id}
               
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post add_menu_item" do
    before do
      @website_nav = Factory.create(:website_nav, :name => "Some Name")
      @website.website_navs << @website_nav
      @website_nav_item = Factory.create(:website_nav_item)
      @website_nav.items << @website_nav_item
    end
    
    it "should return success:true and node given :klass => WebsiteNav and :link_to => url" do
      post :foo, {:use_route => :knitkit,
                 :action => "add_menu_item",
                 :klass => "WebsiteNav",
                 :id => @website_nav.id,
                 :title => "some title",
                 :link_to => "url",
                 :url => "some_url"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["node"].should include(
        {"text" => "some title", "linkToType" => "url", "linkedToId" => nil,
         "websiteId" => @website_nav.website.id, "url" => "some_url", "isSecure" => false,
         "canAddMenuItems" => true, "websiteNavItemId" => 2,
         "iconCls" => "icon-document", "isWebsiteNavItem" => true, "leaf" => false,
         "children" => []})
    end

    it "should return success:true and node given :klass => WebsiteNav and :link_to => website_section" do
      @website_section = Factory.create(:website_section)
      @website.website_sections << @website_section

      post :foo, {:use_route => :knitkit,
                 :action => "add_menu_item",
                 :klass => "WebsiteNav",
                 :id => @website_nav.id,
                 :title => "some title",
                 :link_to => "website_section",
                 :website_section_id => @website_section.id}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["node"].should include(
        {"text" => "some title", "linkToType" => "website_section", "linkedToId" => @website_section.id.to_s,
         "websiteId" => @website_nav.website.id, "url" => "http:///some_section_title", "isSecure" => false,
         "canAddMenuItems" => true, "websiteNavItemId" => 2,
         "iconCls" => "icon-document", "isWebsiteNavItem" => true, "leaf" => false,
         "children" => []})
    end

    it "should return success:true and node given :klass => WebsiteNavItem and :link_to => url" do
      post :foo, {:use_route => :knitkit,
                 :action => "add_menu_item",
                 :klass => "WebsiteNavItem",
                 :id => @website_nav_item.id,
                 :title => "some title",
                 :link_to => "url",
                 :url => "some_url"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["node"].should include(
        {"text" => "some title", "linkToType" => "url", "linkedToId" => nil,
         "websiteId" => @website_nav.website.id, "url" => "some_url", "isSecure" => false,
         "canAddMenuItems" => true, "websiteNavItemId" => 2,
         "iconCls" => "icon-document", "isWebsiteNavItem" => true, "leaf" => false,
         "children" => []})
    end

    it "should return success:true and node given :klass => WebsiteNavItem and :link_to => website_section" do
      @website_section = Factory.create(:website_section)
      @website.website_sections << @website_section

      post :foo, {:use_route => :knitkit,
                 :action => "add_menu_item",
                 :klass => "WebsiteNavItem",
                 :id => @website_nav_item.id,
                 :title => "some title",
                 :link_to => "website_section",
                 :website_section_id => @website_section.id}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["node"].should include(
        {"text" => "some title", "linkToType" => "website_section", "linkedToId" => @website_section.id.to_s,
         "websiteId" => @website_nav.website.id, "url" => "http:///some_section_title", "isSecure" => false,
         "canAddMenuItems" => true, "websiteNavItemId" => 2,
         "iconCls" => "icon-document", "isWebsiteNavItem" => true, "leaf" => false,
         "children" => []})
    end
  end

  describe "Post update_menu_item" do
    before do
      @website_nav = Factory.create(:website_nav, :name => "Some Name")
      @website.website_navs << @website_nav
      @website_nav_item = Factory.create(:website_nav_item)
      @website_nav.items << @website_nav_item
    end

    it "should return success:true title linkedToId linkToType and url given link_to => url" do
      post :foo, {:use_route => :knitkit,
                 :action => "update_menu_item",
                 :website_nav_item_id => @website_nav_item.id,
                 :title => "some title",
                 :url => "some_url",
                 :link_to => "url"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["title"].should eq("some title")
      parsed_body["linkedToId"].should eq(nil)
      parsed_body["linkToType"].should eq("url")
      parsed_body["url"].should eq("some_url")
    end

    it "should return success:true title linkedToId linkToType and url given link_to => website_section" do
      @website_section = Factory.create(:website_section)
      @website.website_sections << @website_section

      post :foo, {:use_route => :knitkit,
                 :action => "update_menu_item",
                 :website_nav_item_id => @website_nav_item.id,
                 :title => "some title",
                 :website_section_id => @website_section.id,
                 :link_to => "website_section"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["title"].should eq("some title")
      parsed_body["linkedToId"].should eq(@website_section.id.to_s)
      parsed_body["linkToType"].should eq("website_section")
      parsed_body["url"].should eq("http:///some_section_title")
    end
  end

  describe "Post update_security" do
    before do
      @website_nav = Factory.create(:website_nav, :name => "Some Name")
      @website.website_navs << @website_nav
      @website_nav_item = Factory.create(:website_nav_item)
      @website_nav.items << @website_nav_item
    end
    
    it "should call add_role on website_nav_item and return success:true given :secure => true" do
      @website_nav_item_double = double("WebsiteNavItem")
      WebsiteNavItem.should_receive(:find).and_return(@website_nav_item_double)
      @website_nav_item_double.should_receive(:add_role)
      
      post :foo, {:use_route => :knitkit,
                 :action => "update_security",
                 :id => @website_nav_item.id,
                 :site_id => @website.id,
                 :secure => "true"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

    it "should call remove_role on wbsite_nav_item and return success:true given :secure => false" do
      @website_nav_item_double = double("WebsiteNavItem")
      WebsiteNavItem.should_receive(:find).and_return(@website_nav_item_double)
      @website_nav_item_double.should_receive(:remove_role)

      post :foo, {:use_route => :knitkit,
                 :action => "update_security",
                 :id => @website_nav_item.id,
                 :site_id => @website.id,
                 :secure => "false"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post delete_menu_item" do
    before do
      @website_nav = Factory.create(:website_nav, :name => "Some Name")
      @website.website_navs << @website_nav
      @website_nav_item = Factory.create(:website_nav_item)
      @website_nav.items << @website_nav_item
    end
    
    it "should call destroy on WebsiteNavId with website_nav_item.id" do
      WebsiteNavItem.should_receive(:destroy).with(@website_nav_item.id.to_s)

      post :foo, {:use_route => :knitkit,
                 :action => "delete_menu_item",
                 :id => @website_nav_item.id.to_s}

    end
  end
end