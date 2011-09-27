class CompassAeInstance < ActiveRecord::Base
  has_file_assets
  
  def installed_engines
    Rails::Application::Railties.engines.map{|e| 
      name = e.railtie_name.camelize
      ErpBaseErpSvcs::ENGINES.include?(name) ? {:name => name, :version => ("#{name}::VERSION".constantize rescue 'N/A')} : nil
    }.delete_if {|x| x == nil}
  end
  
end