require 'rails_db_admin/extjs'
require 'rails_db_admin/connection_handler'
require 'rails_db_admin/query_support'
require 'rails_db_admin/table_support'
require "rails_db_admin/engine"

module RailsDbAdmin
  #Default location where queries are saved. Overide in your rails app as necessary
  QUERY_LOCATION ||= "#{Rails.root}/public/rails_db_admin/queries/"
end


