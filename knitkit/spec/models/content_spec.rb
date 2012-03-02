require 'spec_helper'

describe Content do
  it "can be instantiated" do
    Content.new.should be_an_instance_of(Content)
  end

  #it "can be saved successfully" do
  #  Content.create(:type => 'Page', :title => 'Test').should be_persisted
  #end

  describe "self.find_by_section_id" do
    it "should return all articles belonging to the given section" do
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article")

      website_section = WebsiteSection.create(:title => "section title")
      article.website_sections << website_section

      results = Content.find_by_section_id(1)
      results.should include(article)
    end
  end

  describe "self.find_by_section_id_filtered_by_id" do
    it "should return all articles conected to the given section that also have ids in the given filter list" do
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article")
      article2 = Article.create(:created_by_id => 1, :title => "some article 2")

      website_section = WebsiteSection.create(:title => "section title")
      article.website_sections << website_section
      article2.website_sections << website_section

      results = Content.find_by_section_id_filtered_by_id(1, [1])
      results.should include(article)
      results.should_not include(article2)
    end
  end

  describe "self.find_published_by_section" do
    it "should return all content versions that belong to the given website version and section" do
      @website = Website.create(:name => "Some Site")
      @website.hosts << WebsiteHost.create(:host => "some_host")
      @website.website_sections << WebsiteSection.create(:title => "section title")
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article")

      website_section = WebsiteSection.find(1)
      article.website_sections << website_section

      article.publish(Website.find(1), "some comment", 1, User.find(1))
      @website.set_publication_version(1.1, 1)

      article2 = Article.create(:created_by_id => 1, :title => "some article 2")
      article2.website_sections << website_section

      article_version = article.versions.first
      article_version2 = article2.versions.first

      results = Content.find_published_by_section(PublishedWebsite.find_by_version(0.1), WebsiteSection.find(1))
      results.should include(article_version)
      results.should_not include(article_version2)
    end
  end

  describe "self.find_published_by_section_with_tag" do
    it "should return all content version that belong to the given active_publication and section that have the given tag" do
      @website = Website.create(:name => "Some Site")
      @website.hosts << WebsiteHost.create(:host => "some_host")
      @website.website_sections << WebsiteSection.create(:title => "section title")
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article", :tag_list => "some tag")

      website_section = WebsiteSection.find(1)
      article.website_sections << website_section

      article.publish(Website.find(1), "some comment", 1, User.find(1))
      @website.set_publication_version(1.1, 1)

      article2 = Article.create(:created_by_id => 1, :title => "some article 2")
      article2.website_sections << website_section

      article_version = article.versions.first
      article_version2 = article2.versions.first

      tag = ActsAsTaggableOn::Tag.find_by_name("some tag")

      results = Content.find_published_by_section_with_tag(PublishedWebsite.find_by_version(0.1), WebsiteSection.find(1), tag)
      results.should include(article_version)
      results.should_not include(article_version2)
    end
  end

  describe "find_website_sections_by_site_id" do
    it "should return all the website sections the content belongs to in the given website" do
      @website = Website.create(:name => "Some Site")
      @website.hosts << WebsiteHost.create(:host => "some_host")
      @website.website_sections << WebsiteSection.create(:title => "section title")
      @website.website_sections << WebsiteSection.create(:title => "section title 2")
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article", :tag_list => "some tag")

      website_section = WebsiteSection.find(1)
      website_section2 = WebsiteSection.find(2)
      article.website_sections << website_section
      article.website_sections << website_section2
      
      @website2 = Website.create(:name => "Some Other Site")
      @website2.hosts << WebsiteHost.create(:host => "some_other_host")
      @website2.website_sections << WebsiteSection.create(:title => "section other title")

      other_website_section = WebsiteSection.find_by_title("section other title")
      article.website_sections << other_website_section

      results = article.find_website_sections_by_site_id(1)
      results.should include(website_section)
      results.should include(website_section2)
      results.should_not include(other_website_section)
    end
  end

  describe "position" do
    it "should return the position of the content in the website_section with the given id" do
      @website = Website.create(:name => "Some Site")
      @website.hosts << WebsiteHost.create(:host => "some_host")
      @website.website_sections << WebsiteSection.create(:title => "section title")
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article", :tag_list => "some tag")

      website_section = WebsiteSection.find(1)
      article.website_sections << website_section
      
      article.position(1).should eq(0)
    end
  end

  describe "add_comment" do
    it "should add a comment to the article" do
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article", :tag_list => "some tag")

      article.add_comment(:comment => "some comment")

      article.comments.first.comment.should eq("some comment")
    end
  end

  describe "get_comments" do
    it "should return all comments for an article limited by the given limit" do
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article", :tag_list => "some tag")

      article.add_comment(:comment => "some comment")

      article.get_comments(1).first.comment.should eq("some comment")
    end
  end

  describe "update_content_area_and_position_by_section" do
    it "should update the content area and position of the content in the given section" do
      @website = Website.create(:name => "Some Site")
      @website.hosts << WebsiteHost.create(:host => "some_host")
      @website.website_sections << WebsiteSection.create(:title => "section title")
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      article = Article.create(:created_by_id => 1, :title => "some article", :tag_list => "some tag")

      website_section = WebsiteSection.find(1)
      article.website_sections << website_section

      article.update_content_area_and_position_by_section(website_section, "some_area", 1)

      article.position(1).should eq(1)
      website_section_content = WebsiteSectionContent.where('content_id = ? and website_section_id = ?',article.id, 1).first
      website_section_content.content_area.should eq("some_area")
    end
  end
end