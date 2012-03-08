class CompassAeInstance < ActiveRecord::Base
  has_file_assets
  
  def installed_engines
    Rails.application.config.erp_base_erp_svcs.compass_ae_engines.map do |compass_ae_engine|
      {:name => compass_ae_engine.railtie_name.camelize, :version => ("#{compass_ae_engine.railtie_name.camelize}::VERSION::STRING".constantize rescue 'N/A')}
    end
  end
  
end