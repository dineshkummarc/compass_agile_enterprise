require 'spec_helper'

describe Article do
  it "can be instantiated" do
    Article.new.should be_an_instance_of(Article)
  end

  it "can be saved successfully" do
    WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
    WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
    Article.create(:created_by_id => 1).should be_persisted
  end

  describe "to_param" do
    it "should return the permalink of the article" do
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      Article.create(:created_by_id => 1, :title => "article 2").to_param.should eq('article-2')
    end
  end

  describe "check_internal_indentifier" do
    it "should set the internal_identifier if none is set when article is created" do
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      Article.create(:created_by_id => 1, :title => "article 2").internal_identifier.should eq('article-2')
    end

    it "should not change the internal_identifier if one is set when article is created" do
      WorkflowProcess.create(:internal_identifier => "test_content_mgmt", :process_template => true)
      WorkflowStep.create(:internal_identifier => "Start", :executable_command_id => 1, :executable_command_type => "ManualWorkflowStep", :workflow_process_id => 1, :initial_step => true)
      Article.create(:created_by_id => 1, :title => "article 2", :internal_identifier => "some_identifier").internal_identifier.should eq('some_identifier')
    end
  end
end