require File.dirname(__FILE__) + '/test_helper'

class TabnavHelperTest < Test::Unit::TestCase
  include Widgets::TabnavHelper
  attr_accessor :output_buffer

  EXPECTED_INSTANCE_METHODS = %w{tabnav render_tabnav add_tab}

  def setup
    self.output_buffer= ''
  end
    
  def test_presence_of_instance_methods
    EXPECTED_INSTANCE_METHODS.each do |instance_method|
      assert respond_to?(instance_method), "#{instance_method} is not defined in #{self.inspect}"
    end     
  end  
  
end
