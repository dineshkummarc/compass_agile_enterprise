require 'spec_helper'

describe Blog do
  it "can be instantiated" do
    Blog.new.should be_an_instance_of(Blog)
  end

  it "can be saved successfully" do
    Blog.create(:title => "Some Title").should be_persisted
  end
  
  it "can find_blog_post" do
    blog = Blog.create(:title => "some title")
    blog.find_blog_post('test')
  end
end
