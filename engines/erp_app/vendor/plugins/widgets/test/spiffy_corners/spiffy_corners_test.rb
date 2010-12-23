#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'

class SpiffyCornersHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::CaptureHelper
  include Widgets::SpiffyCorners::SpiffyCornersHelper
  attr_accessor :params
  attr_accessor :output_buffer

  def setup
    self.params = {}
    self.output_buffer= ''
  end
    
  def test_simple_with_css
    expected = load_template('spiffy_corners/simple.html') 

    spiffy_corners(:generate_css => true) do concat("Ciccio"); end
    assert_equal expected, self.output_buffer
  end
end
