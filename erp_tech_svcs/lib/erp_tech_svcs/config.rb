module ErpTechSvcs
  module Config
    class << self
      attr_accessor :max_file_size_in_mb, :installation_domain, :login_url, :email_notifications_from

      def init!
        @defaults = {
          :@max_file_size_in_mb => 5,
          :@installation_domain => 'localhost:3000',
          :@login_url => '/erp_app/login',
          :@email_notifications_from => 'notifications@noreply.com'
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
