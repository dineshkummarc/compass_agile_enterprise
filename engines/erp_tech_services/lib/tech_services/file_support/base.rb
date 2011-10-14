module TechServices
  module FileSupport
    DEFAULT_OPTIONS = {
      :knitkit_storage => :filesystem
    }
      
    mattr_accessor :options
    @@options = HashWithIndifferentAccess.new(DEFAULT_OPTIONS)
      
    class Base
      attr_accessor :storage
      
      def initialize(options={})
        @storage = options[:storage].nil? ? :filesystem : options[:storage]
        
        case @storage
        when :s3
          @manager = S3Manager.new
        when :filesystem
          @manager = FileSystemManager.new
        end
      end
      
      def method_missing(m, *args, &block)
        @manager.respond_to?(m) ? @manager.send(m, *args) : super
      end
    
    end
  end
end