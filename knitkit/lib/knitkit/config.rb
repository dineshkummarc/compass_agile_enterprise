module Knitkit
  module Config
    class << self
      attr_accessor :unauthorized_url, 
                    :ignored_prefix_paths, 
                    :file_assets_location, 
                    :cache_expiration_in_minutes

      def init!
        @defaults = {
          :@unauthorized_url => '/unauthorized',
          :@ignored_prefix_paths => [],
          :@file_assets_location => 'knitkit_assets',
          :@cache_expiration_in_minutes => 300
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