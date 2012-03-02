require "spec_helper"
require "erp_dev_svcs"

describe Knitkit::ErpApp::Desktop::WebsiteController do
  before(:each) do
    basic_user_auth_with_admin
    @user = User.first
    @website = Factory.create(:website, :name => "Some name")
    @website.hosts << Factory.create(:website_host)
  end

  describe "Get index" do
    it "should return :sites => Website.all" do
      get :foo, {:use_route => :knitkit,
                 :action => "index"}

      parsed_body = JSON.parse(response.body)
      parsed_body["sites"][0].should include(
        {"auto_activate_publication"=>nil, "email"=>nil, "email_inquiries"=>nil,
         "id"=>1, "name"=>"Some name", "subtitle"=>nil, "title"=>"Some Title!"})
    end
  end

  describe "Get website_publications" do
    it "should return the correct info with session[:website_version] blank" do
      get :foo, {:use_route => :knitkit,
                 :action => "website_publications",
                 :id => @website.id}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["results"].should eq(1)
      parsed_body["totalCount"].should eq(1)
      parsed_body["data"][0]["active"].should eq(true)
      parsed_body["data"][0]["comment"].should eq("New Site Created")
      parsed_body["data"][0]["id"].should eq(1)
      parsed_body["data"][0]["version"].should eq("0.0")
      parsed_body["data"][0]["viewing"].should eq(true)
      parsed_body["data"][0]["published_by_username"].should eq("")
      parsed_body["data"][0]["created_at"].should be_a(String)
    end

    it "should return the correct info with session[:website_version] not blank" do
      session[:website_version] = [{:website_id => @website.id, :version => "1.0"}]
      get :foo, {:use_route => :knitkit,
                 :action => "website_publications",
                 :id => @website.id}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["results"].should eq(1)
      parsed_body["totalCount"].should eq(1)
      parsed_body["data"][0]["active"].should eq(true)
      parsed_body["data"][0]["comment"].should eq("New Site Created")
      parsed_body["data"][0]["id"].should eq(1)
      parsed_body["data"][0]["version"].should eq("0.0")
      parsed_body["data"][0]["viewing"].should eq(false)
      parsed_body["data"][0]["published_by_username"].should eq("")
      parsed_body["data"][0]["created_at"].should be_a(String)
    end
  end

  describe "Post activate_publication" do
    it "should call set_publication_version with version number on website and return success:true" do
      @website.published_websites << Factory.create(:published_website, :version => 1, :comment => "published_website test", :published_by_id => 1)
      @website_double = double("Website")
      Website.should_receive(:find).and_return(@website_double)
      @website_double.should_receive(:id).and_return(1)
      @website_double.should_receive(:set_publication_version).with(1.0, @user)

      post :foo, {:use_route => :knitkit,
                 :action => "activate_publication",
                 :id => @website.id,
                 :version => "1.0"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post set_viewing_version" do
    it "should set session[:website_version] properly when session[:website_version] is blank" do
      post :foo, {:use_route => :knitkit,
                 :action => "set_viewing_version",
                 :id => @website.id,
                 :version => "1.0"}

      session[:website_version].should include({:website_id => @website.id, :version => "1.0"})
    end

    it "should set session[:website_version] properly when session[:website_version] is not blank" do
      session[:website_version]=[]
      session[:website_version] << {:website_id => @website.id, :version => "2.0"}
      
      post :foo, {:use_route => :knitkit,
                 :action => "set_viewing_version",
                 :id => @website.id,
                 :version => "1.0"}

      session[:website_version].should include({:website_id => @website.id, :version => "1.0"})
    end

    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                 :action => "set_viewing_version",
                 :id => @website.id,
                 :version => "1.0"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post publish" do
    it "should call publish on @website and return success:true" do
      @website_double = double("Website")
      Website.should_receive(:find).and_return(@website_double)
      @website_double.should_receive(:publish)

      post :foo, {:use_route => :knitkit,
                 :action => "publish",
                 :id => @website.id,
                 :comment => "some comment"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post new" do
    it "should create a new Website with name some name and set each param for that Website" do
      post :foo, {:use_route => :knitkit,
                  :action => "new",
                  :auto_activate_publication => "no",
                  :email => "some@email.com",
                  :email_inquiries => "no",
                  :host => "some_host",
                  :subtitle =>  "some sub title",
                  :title => "some title",
                  :name => "some name"
                  }

      @new_website = Website.find_by_name("some name")
      @new_website.subtitle.should                  eq("some sub title")
      @new_website.title.should                     eq("some title")
      @new_website.email.should                     eq("some@email.com")
      @new_website.email_inquiries.should            eq(false)
      @new_website.auto_activate_publication.should eq(false)
    end

    it "should create a WebsiteSection named home and link it to website" do
      post :foo, {:use_route => :knitkit,
                  :action => "new",
                  :auto_activate_publication => "no",
                  :email => "some@email.com",
                  :email_inquiries => "no",
                  :host => "some_host",
                  :subtitle =>  "some sub title",
                  :title => "some title",
                  :name => "some name"
                  }
      home_section_exists = false
      @new_website = Website.find_by_name("some name")
      @new_website.website_sections.each do |section|
       home_section_exists = true if section.internal_identifier == "home"
      end

      home_section_exists.should eq(true)

    end

    it "should setup_default_pages on website" do
      post :foo, {:use_route => :knitkit,
                  :action => "new",
                  :auto_activate_publication => "no",
                  :email => "some@email.com",
                  :email_inquiries => "no",
                  :host => "some_host",
                  :subtitle =>  "some sub title",
                  :title => "some title",
                  :name => "some name"
                  }

      count = 0
      @new_website = Website.find_by_name("some name")
      @new_website.website_sections.each do |section|
       case
          when section.title == "Contact Us"
            count +=1 if section.website_id == @new_website.id
          when section.title == "Search"
            count +=1 if section.website_id == @new_website.id
          when section.title == "Manage Profile"
            count +=1 if section.website_id == @new_website.id
          when section.title == "Login"
            count +=1 if section.website_id == @new_website.id
          when section.title == "Sign Up"
            count +=1 if section.website_id == @new_website.id
          when section.title == "Reset Password"
            count +=1 if section.website_id == @new_website.id
        end
      end
      count.should eq(@new_website.website_sections.count - 1)
    end

    it "should create a host and assign it to website.hosts" do
      post :foo, {:use_route => :knitkit,
                  :action => "new",
                  :auto_activate_publication => "no",
                  :email => "some@email.com",
                  :email_inquiries => "no",
                  :host => "some_host",
                  :subtitle =>  "some sub title",
                  :title => "some title",
                  :name => "some name"
                  }

      @new_website = Website.find_by_name("some name")
      @new_website.hosts.each do |host|
        host.host.should eq("some_host")
      end
    end

    it "should publish website" do
      post :foo, {:use_route => :knitkit,
                  :action => "new",
                  :auto_activate_publication => "no",
                  :email => "some@email.com",
                  :email_inquiries => "no",
                  :host => "some_host",
                  :subtitle =>  "some sub title",
                  :title => "some title",
                  :name => "some name"
                  }

      @new_website = Website.find_by_name("some name")
      @new_website.published_websites.count.should eq(2)
    end

    it "should activate the new publication" do
      post :foo, {:use_route => :knitkit,
                  :action => "new",
                  :auto_activate_publication => "no",
                  :email => "some@email.com",
                  :email_inquiries => "no",
                  :host => "some_host",
                  :subtitle =>  "some sub title",
                  :title => "some title",
                  :name => "some name"
                  }

      @new_website = Website.find_by_name("some name")
      @active_website = @new_website.published_websites.find_by_active(true)
      @active_website.version.should eq(1.0)
    end

    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                  :action => "new",
                  :auto_activate_publication => "no",
                  :email => "some@email.com",
                  :email_inquiries => "no",
                  :host => "some_host",
                  :subtitle =>  "some sub title",
                  :title => "some title",
                  :name => "some name"
                  }
      
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end

  end

  describe "Post update" do
    it "should set new params and return true" do
      @test_website = Website.new(:name => "some name",
                                  :title => "some title",
                                  :subtitle => "some sub title",
                                  :email_inquiries => "no",
                                  :email => "some@email.com",
                                  :auto_activate_publication => "no")
      @test_website.save

      Website.should_receive(:find).and_return(@test_website)

      post :foo, {:use_route => :knitkit,
                  :action => "update",
                  :id => @test_website.id,
                  :auto_activate_publication => "yes",
                  :email => "somenew@email.com",
                  :email_inquiries => "yes",
                  :subtitle =>  "some new sub title",
                  :title => "some new title",
                  :name => "some new name"
                  }

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      
      @test_website.name.should eq("some new name")
      @test_website.title.should eq("some new title")
      @test_website.subtitle.should eq("some new sub title")
      @test_website.email_inquiries.should eq(true)
      @test_website.auto_activate_publication.should eq(true)
      @test_website.email.should eq("somenew@email.com")
    end
  end

  describe "Post delete" do
    it "should call destroy on @website" do
      @website_double = double("Website")
      Website.should_receive(:find).and_return(@website_double)
      @website_double.should_receive(:destroy)

      post :foo, {:use_route => :knitkit,
                 :action => "delete",
                 :id => @website.id}
    end

    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                 :action => "delete",
                 :id => @website.id}
               
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post add_host" do
    it "should return success:true and node" do
      @website_host = Factory.create(:website_host, :host => "localhost:3000")
      WebsiteHost.should_receive(:create).and_return(@website_host)
      post :foo, {:use_route => :knitkit,
                 :action => "add_host",
                 :id => @website.id,
                 :host => "localhost:3000"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
      parsed_body["node"].should include(
        {"text" => "localhost:3000",
        "websiteHostId" => @website_host.id,
        "host" => "localhost:3000",
        "iconCls" => 'icon-globe',
        "url" => "http://localhost:3000",
        "isHost" => true,
        "leaf" => true,
        "children" => []})
    end
  end

  describe "Post update_host" do
    it "should set host and save" do
      @website_host = Factory.create(:website_host, :host => "some host")
      WebsiteHost.should_receive(:find).and_return(@website_host)
      @website_host.should_receive(:save)
      
      post :foo, {:use_route => :knitkit,
                 :action => "update_host",
                 :id => @website.id,
                 :host => "localhost:3000"}

      @website_host.host.should eq("localhost:3000")
    end

    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                 :action => "update_host",
                 :id => @website.id,
                 :host => "localhost:3000"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post delete_host" do
    it "should call destroy on WebsiteHost with params[:id]" do
      WebsiteHost.should_receive(:destroy).with("1")
      
      post :foo, {:use_route => :knitkit,
                 :action => "delete_host",
                 :id => "1"}
    end

    it "should return success:true" do
      post :foo, {:use_route => :knitkit,
                 :action => "delete_host",
                 :id => "1"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end
end
