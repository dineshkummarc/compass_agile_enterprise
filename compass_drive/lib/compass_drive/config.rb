module CompassDrive
  module Config
    class << self
      attr_accessor :compass_drive_directory

      def init!
        @defaults = {
          :@compass_drive_directory => "compass_drive"
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