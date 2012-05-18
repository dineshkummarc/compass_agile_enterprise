module ErpTechSvcs
  module Config
    class << self
      attr_accessor :max_file_size_in_mb, 
                    :installation_domain, 
                    :login_url,
                    :email_notifications_from, 
                    :file_assets_location, 
                    :s3_url_expires_in_seconds,
                    :s3_protocol,
                    :file_storage,
                    :s3_cache_expires_in_minutes,
                    :session_expires_in_hours

      def init!
        @defaults = {
          :@max_file_size_in_mb => 5,
          :@installation_domain => 'localhost:3000',
          :@login_url => '/erp_app/login',
          :@email_notifications_from => 'notifications@noreply.com',
          :@file_assets_location => 'file_assets', # relative to Rails.root/
          :@s3_url_expires_in_seconds => 60,
          :@s3_protocol => 'https', # Can be either 'http' or 'https'
          :@file_storage => :filesystem, # Can be either :s3 or :filesystem
          :@s3_cache_expires_in_minutes => 60,
          :@session_expires_in_hours => 12 # this is used by DeleteExpiredSessionsJob to purge inactive sessions from database 
        }
      end

      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end
      end

      def configure(&blk)
        @configure_blk = blk
      end

      def configure!
        @configure_blk.call(self) if @configure_blk
      end
    end
    init!
    reset!
  end
end
