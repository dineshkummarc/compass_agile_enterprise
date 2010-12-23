require File.dirname(__FILE__) + '/../test_helper'
require 'test/unit'

# tableless model
class Post < ActiveRecord::Base
  def create_or_update
    errors.empty?
  end

  def self.columns()
    @columns ||= []
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
end

class TestTemplate < ActionView::Template
  include ActionView::Helpers::CaptureHelper
  attr_accessor :output_buffer
  def initialize
    super(File.dirname(__FILE__), 'template.erb')
  end
end

class ShowhideHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include Widgets::ShowhideHelper

  attr_accessor :params
  attr_accessor :template
  attr_accessor :output_buffer

  def setup
    @post = Post.new
    self.params= {}
    self.output_buffer= ''
    self.template = TestTemplate.new
  end

  EXPECTED_INSTANCE_METHODS = %w{show_box_for detail_box_for hide_box_for}

  def test_presence_of_instance_methods
    EXPECTED_INSTANCE_METHODS.each do |instance_method|
      assert respond_to?(instance_method), "#{instance_method} is not defined after including the helper"
    end
  end

  def test_show_box_for_with_defaults_for_new
    expected = "<a class=\"details_show_link\" href=\"#\" id=\"show_details_for_new_post\" onclick=\"$(&quot;details_for_new_post&quot;).show();\n$(&quot;show_details_for_new_post&quot;).hide();; return false;\">show details</a>"
    assert_equal expected, show_box_for(@post)
  end

  def test_show_box_for_with_defaults
    @post[:id]=23
    expected = "<a class=\"details_show_link\" href=\"#\" id=\"show_details_for_post_23\" onclick=\"$(&quot;details_for_post_23&quot;).show();\n$(&quot;show_details_for_post_23&quot;).hide();; return false;\">show details</a>"
    assert_equal expected, show_box_for(@post)
  end

  def test_show_box_for_with_name_for_new
    expected = "<a class=\"happyness_show_link\" href=\"#\" id=\"show_happyness_for_new_post\" onclick=\"$(&quot;happyness_for_new_post&quot;).show();\n$(&quot;show_happyness_for_new_post&quot;).hide();; return false;\">show details</a>"
    assert_equal expected, show_box_for(@post, :name=>'happyness')
  end

  def test_show_box_for_with_name
    @post[:id]=23
    expected = "<a class=\"happyness_show_link\" href=\"#\" id=\"show_happyness_for_post_23\" onclick=\"$(&quot;happyness_for_post_23&quot;).show();\n$(&quot;show_happyness_for_post_23&quot;).hide();; return false;\">show details</a>"
    assert_equal expected, show_box_for(@post, :name=>'happyness')
  end

  def test_show_box_for_with_full_params
    expected = "<a class=\"custom_css_class\" href=\"#\" id=\"custom_html_id\" onclick=\"$(&quot;custom_detail_box_id&quot;).show();\n$(&quot;custom_html_id&quot;).hide();; return false;\">custom_link_name</a>"
    assert_equal expected, show_box_for(@post, default_params.merge(:name=>'must_be_overrided'))
  end

  def test_show_box_if_not_ar
    expected = "<a class=\"details_show_link\" href=\"#\" id=\"show_details_for_my_wonderful-name\" onclick=\"$(&quot;details_for_my_wonderful-name&quot;).show();\n$(&quot;show_details_for_my_wonderful-name&quot;).hide();; return false;\">show details</a>"
    assert_equal expected, show_box_for('my_wonderful-name')
  end

  ## hide

  def test_hide_box_for_with_defaults_for_new
    expected = "<a class=\"details_hide_link\" href=\"#\" id=\"hide_details_for_new_post\" onclick=\"$(&quot;details_for_new_post&quot;).hide();\n$(&quot;show_details_for_new_post&quot;).show();; return false;\">hide details</a>"
    assert_equal expected, hide_box_for(@post)
  end

  def test_hide_box_for_with_defaults
    @post[:id]=54
    expected = "<a class=\"details_hide_link\" href=\"#\" id=\"hide_details_for_post_54\" onclick=\"$(&quot;details_for_post_54&quot;).hide();\n$(&quot;show_details_for_post_54&quot;).show();; return false;\">hide details</a>"
    assert_equal expected, hide_box_for(@post)
  end

  def test_hide_box_for_with_name_for_new
    expected = "<a class=\"fear_hide_link\" href=\"#\" id=\"hide_fear_for_new_post\" onclick=\"$(&quot;fear_for_new_post&quot;).hide();\n$(&quot;show_fear_for_new_post&quot;).show();; return false;\">hide details</a>"
    assert_equal expected, hide_box_for(@post, :name=>'fear')
  end

  def test_hide_box_for_with_name
    @post[:id]=54
    expected = "<a class=\"fear_hide_link\" href=\"#\" id=\"hide_fear_for_post_54\" onclick=\"$(&quot;fear_for_post_54&quot;).hide();\n$(&quot;show_fear_for_post_54&quot;).show();; return false;\">hide details</a>"
    assert_equal expected, hide_box_for(@post, :name=>'fear')
  end

  def test_hide_box_for_with_full_params
    expected = "<a class=\"custom_css_class\" href=\"#\" id=\"custom_html_id\" onclick=\"$(&quot;custom_detail_box_id&quot;).hide();\n$(&quot;custom_show_link_id&quot;).show();; return false;\">custom_link_name</a>"
    assert_equal expected, hide_box_for(@post, default_params.merge(:name=>'must_be_overrided'))
  end

  def test_hide_box_if_non_ar
    expected = "<a class=\"details_hide_link\" href=\"#\" id=\"hide_details_for_my_wonderful-name\" onclick=\"$(&quot;details_for_my_wonderful-name&quot;).hide();\n$(&quot;show_details_for_my_wonderful-name&quot;).show();; return false;\">hide details</a>"
    assert_equal expected, hide_box_for('my_wonderful-name')
  end

  ## detail

  def test_detail_box_should_raise_argument_error
    assert_raise(ArgumentError) do
      detail_box_for @post
    end
  end

  def test_detail_box_css_generation
    expected = "<style>\n  .details_for_post {\n    background: #FFFABF;\n    border: solid 1px #cccccc;\n    padding: 10px;\n    margin-bottom: 5px;\n  }\n</style>\n"+
      "<div class=\"details_for_post\" id=\"details_for_new_post\" style=\"display:none;\">nice Content</div>"
    assert_nothing_raised do
      detail_box_for @post, :generate_css=>true do
        output_buffer.concat 'nice Content'
      end
    end
    assert_equal expected, output_buffer
  end

  def test_detail_box_with_defaults_for_new
    expected = "<div class=\"details_for_post\" id=\"details_for_new_post\" style=\"display:none;\">nice Content</div>"
    assert_nothing_raised do
      detail_box_for @post do
        output_buffer.concat 'nice Content'
      end
    end
    assert_equal expected, output_buffer
  end

  def test_detail_box_with_defaults
    @post[:id]=87
    expected = "<div class=\"details_for_post\" id=\"details_for_post_87\" style=\"display:none;\">nice Content</div>"
    assert_nothing_raised do
      detail_box_for @post do
        output_buffer.concat 'nice Content'
      end
    end
    assert_equal expected, output_buffer
  end

  def test_detail_box_with_name_for_new
    expected = "<div class=\"master_for_post\" id=\"master_for_new_post\" style=\"display:none;\">nice Content</div>"
    assert_nothing_raised do
      detail_box_for @post, :name=>'master' do
        output_buffer.concat 'nice Content'
      end
    end
    assert_equal expected, output_buffer
  end

  def test_detail_box_with_name
    @post[:id]=87
    expected = "<div class=\"master_for_post\" id=\"master_for_post_87\" style=\"display:none;\">nice Content</div>"
    assert_nothing_raised do
      detail_box_for @post, :name=>'master' do
        output_buffer.concat 'nice Content'
      end
    end
    assert_equal expected, output_buffer
  end

  def test_detail_box_with_full_params
    expected = "<div class=\"custom_css_class\" id=\"custom_html_id\" style=\"display:none;\">nice Content</div>"
    assert_nothing_raised do
      detail_box_for @post, default_params.merge(:name=>'must_be_overrided') do
        output_buffer.concat 'nice Content'
      end
    end
    assert_equal expected, output_buffer
  end

  def test_detail_box_if_not_ar
    expected = "<div class=\"details_for_my_wonderful-name\" id=\"details_for_my_wonderful-name\" style=\"display:none;\">nice Content</div>"
    assert_nothing_raised do
      detail_box_for 'my_wonderful-name' do
        output_buffer.concat 'nice Content'
      end
    end
    assert_equal expected, output_buffer
  end

  private

  def default_params
    return {:html => {:id=>'custom_html_id', :class=>'custom_css_class'},
      :name => 'custom_name',
      :show_link_id => 'custom_show_link_id',
      :link_name => 'custom_link_name',
      :detail_box_id => 'custom_detail_box_id'}
  end
end
