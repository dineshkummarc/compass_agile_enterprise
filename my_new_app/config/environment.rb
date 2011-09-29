# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MyNewApp::Application.initialize!

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => '127.0.0.1',
  :port => 25
}