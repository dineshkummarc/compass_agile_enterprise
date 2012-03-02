class CompassAeInstance < ActiveRecord::Base
  has_file_assets
  
  def installed_engines
    Rails::Application::Railties.engines.map{|e| 
      name = e.railtie_name.camelize
      Rails.application.config.erp_base_erp_svcs.compass_ae_engines.include?(name) ? {:name => name, :version => ("#{name}::VERSION".constantize rescue 'N/A')} : nil
    }.delete_if {|x| x == nil}
  end
  
end