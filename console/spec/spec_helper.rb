ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
DUMMY_APP_ROOT=File.join(File.dirname(__FILE__), '/dummy')

require 'active_support'
require 'active_model'
require 'active_record'
require 'action_controller'

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "spec"
require File.expand_path(DUMMY_APP_ROOT + "/config/environment.rb",  __FILE__)

ActiveRecord::Base.configurations = YAML::load(IO.read(DUMMY_APP_ROOT + "/config/database.yml"))
ActiveRecord::Base.establish_connection(ENV["DB"] || "spec")
ActiveRecord::Migration.verbose = false
load(File.join(DUMMY_APP_ROOT, "db", "schema.rb"))

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

require 'rspec/rails'
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end