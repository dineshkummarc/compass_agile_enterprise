require 'spec_helper'

describe OnlineDocumentSection, "#build_section_hash" do
  let!(:website) { Factory.create(:website, :name => "Website")}
  let!(:root_section) { Factory.create(:online_document_section, :title => "Parent", :website => website, :in_menu => true)}
  let!(:root_documented_content) { Factory.create(:documented_content, :title => "Parent")}
  let!(:root_documented_item) { Factory.create(:documented_item, 
                                            :online_document_section => root_section, 
                                            :documented_content_id => root_documented_content.id, 
                                            :online_document_section => root_section) }
  
  let!(:child_section) { Factory.create(:online_document_section, :title => "Child", :parent => root_section, :website => website, :in_menu => true)}                                          
  let!(:child_documented_content) { Factory.create(:documented_content, :title => "Child")}
  let!(:child_documented_item) { Factory.create(:documented_item, 
                                            :online_document_section => child_section, 
                                            :documented_content_id => child_documented_content.id, 
                                            :online_document_section => child_section) }
                                            
  before do
    root_section.update_path!
    @root_section_hash = {:name=>"Parent", :has_layout=>false, :type=>"OnlineDocumentSection", :in_menu=>true, :roles=>[], 
      :path=>"/parent", :permalink=>"parent", :internal_identifier=>"parent", 
      :online_document_sections=>[{:name=>"Child", :has_layout=>false, :type=>"OnlineDocumentSection", :in_menu=>true, 
        :roles=>[], :path=>"/parent/child", :permalink=>"child", :internal_identifier=>"child", :online_document_sections=>[], 
        :documented_item=>{:name=>"Child", :display_title=>nil, :internal_identifier=>"child"}}], 
      :documented_item=>{:name=>"Parent", :display_title=>nil, :internal_identifier=>"parent"}}
  end
  
  it "should output the correct hash" do
    root_section.build_section_hash.should == @root_section_hash
  end
  
  
end