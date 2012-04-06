# we need to_prepare so that this is checked multiple times during startup as erp_tech_svcs.file_storage can be overridden. 
Rails.application.config.to_prepare do
  # Rescue here, Compass should not die if it cannot connect to S3
  begin
    ErpTechSvcs::FileSupport::S3Manager.setup_connection() if Rails.application.config.erp_tech_svcs.file_storage == :s3
  rescue Exception => e
    Rails.logger.error "ERROR: Failed to connect to Amazon S3 #{e.inspect}"
  end
end
