
# Rescue here, Compass should not die if it cannot connect to S3
begin
  ErpTechSvcs::FileSupport::S3Manager.setup_connection() if ErpTechSvcs::FileSupport.options[:storage] == :s3
rescue Exception => e
  Rails.logger.error "ERROR: Failed to connect to Amazon S3 #{e.inspect}"
end

