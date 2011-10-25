require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
  DUMMY_APP_ROOT=File.join(File.dirname(__FILE__), '/dummy')



  require 'active_support'
  require 'active_model'
  require 'active_record'
  require 'action_controller'
  #require 'rails/generators'

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


  # Don't need passwords in test DB to be secure, but we would like 'em to be
  # fast -- and the stretches mechanism is intended to make passwords
  # computationally expensive.
  module Devise
    module Models
      module DatabaseAuthenticatable
        protected

        def password_digest(password)
          password
        end
      end
    end
  end
  Devise.setup do |config|
    config.stretches = 0
  end

  RSpec.configure do |config|
    config.use_transactional_fixtures = true
    #this adds in the Devise testhelpers if the test is
    #for a controller
    config.include Devise::TestHelpers, :type => :controller
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  require 'simplecov'

  #Simplecov is a ruby gem that uses Ruby 1.9's built-in coverage module to generate
  #an html report of what lines were hit and total percentages of what was hit
  SimpleCov.start do
    #this command excludes anything in the spec folder from being counted
    #in the simplecov report.  Otherwise our numbers would be skewed
    add_filter "spec/"
    #The add_group command is used to create tabs in the simplecov report.
    #See the simplecov project on Github to see what all the options are.
    add_group "Controllers", "app/controllers"
    add_group "Models", "app/models"
    add_group "Lib", "lib/"
  end

  #Need to explictly load the files in lib/ until we figure out how to 
  #get rails to autoload them for spec like it used to...
  #[CB 2011-OCT-24]  Had to exclude the generators, since there's a lot 
  #dependencies I didn't want to bother figuring out.
  #Dir[File.join(ENGINE_RAILS_ROOT, "lib/**/*.rb")].each {|f| load f}
  Dir[File.join(ENGINE_RAILS_ROOT, "lib/active_ext/**/*.rb")].each {|f| load f}
  Dir[File.join(ENGINE_RAILS_ROOT, "lib/erp_app/**/*.rb")].each {|f| load f}

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.




