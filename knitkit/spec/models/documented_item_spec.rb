require 'spec_helper'

describe DocumentedItem, "klass?" do
  let!(:article) { Factory.create(:article)}
  let!(:klass_documented_item) { Factory.create(:documented_item, :documented_klass => 'Article')}
  let!(:non_klass_documented_item) { Factory.create(:documented_item, :documented_content_id => article.id)}
  
  it "should return true if klass isn't nil" do
    klass_documented_item.klass?.should be_true
  end
  
  it "should return false if klass is nil" do
    non_klass_documented_item.klass?.should be_false
  end
end

describe DocumentedItem, "content?" do
  let!(:article) { Factory.create(:article)}
  let!(:content_documented_item) { Factory.create(:documented_item, :documented_content_id => article.id)}
  let!(:non_content_documented_item) { Factory.create(:documented_item, :documented_klass => 'Article')}
  
  it "should return true if documented_content_id isn't nil" do
    content_documented_item.content?.should be_true
  end
  
  it "should return false if documented_content_id is nil" do
    non_content_documented_item.content?.should be_false
  end
end