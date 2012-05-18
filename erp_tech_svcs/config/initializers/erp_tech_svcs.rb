Rails.application.config.erp_tech_svcs.configure do |config|
  config.installation_domain = 'localhost:3000'
  config.login_url = '/erp_app/login'
  config.email_notifications_from = 'notifications@noreply.com'
  config.max_file_size_in_mb = 5
  config.file_assets_location = 'file_assets' # relative to Rails.root/
  config.s3_url_expires_in_seconds = 60 
  config.s3_protocol = 'https' # Can be either 'http' or 'https'
  config.file_storage = :filesystem # Can be either :s3 or :filesystem
  config.s3_cache_expires_in_minutes = 60 
  config.session_expires_in_hours = 12 # this is used by DeleteExpiredSessionsJob to purge inaactive sessions from database 
end
Rails.application.config.erp_tech_svcs.configure!
