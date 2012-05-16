class CompassAeInstance < ActiveRecord::Base
  has_file_assets
  
  def installed_engines
    Rails.application.config.erp_base_erp_svcs.compass_ae_engines.map do |compass_ae_engine|
      klass_name = compass_ae_engine.railtie_name.camelize
      {:name => klass_name, :version => ("#{klass_name}::VERSION::STRING".constantize rescue 'N/A')}
    end
  end
  
end