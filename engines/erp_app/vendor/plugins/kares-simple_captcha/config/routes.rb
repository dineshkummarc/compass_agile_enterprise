if Rails::VERSION::MAJOR >= 3
  # routes Rails 3.0.0+ style
  Rails.application.routes.draw do
    match '/simple_captcha/:action', :to => 'simple_captcha', :as => :simple_captcha
  end
else
  # Rails 2.3+ supports loading routes for _plugins_ as well :
  ActionController::Routing::Routes.draw do |map|
    map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  end
end
# 4 Rails < 2.3 one needs to manually add this to RAILS_ROOT/config/routes.rb :
=begin
ActionController::Routing::Routes.draw do |map|
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
end
=end