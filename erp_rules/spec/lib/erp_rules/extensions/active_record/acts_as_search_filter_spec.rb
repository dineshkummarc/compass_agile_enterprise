require "spec_helper"

describe ErpRules::Extensions::ActiveRecord::ActsAsSearchFilter do

  before(:each) do
    TestClass = Class.new(ActiveRecord::Base) do 
      acts_as_search_filter
      set_table_name "role_types"
    end
  end

end
