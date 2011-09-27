class CompassAeInstance < ActiveRecord::Base
  has_file_assets
  
  def installed_engines
    Rails::Application::Railties.engines.map{|e| 
      name = e.railtie_name.camelize
      version = "#{name}::VERSION".constantize rescue 'N/A'
      {:name => name, :version => version}
    }
  end
  
end