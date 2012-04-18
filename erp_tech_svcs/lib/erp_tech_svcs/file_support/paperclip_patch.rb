module Paperclip
  module Storage
    module S3
      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          begin
            log("saving #{path(style)}")
            acl = @s3_permissions[style] || @s3_permissions[:default]
            acl = acl.call(self, style) if acl.respond_to?(:call)
            write_options = {
              :content_type => content_type,
              :acl => acl
            }
            write_options[:metadata] = @s3_metadata unless @s3_metadata.empty?
            unless @s3_server_side_encryption.blank?
              write_options[:server_side_encryption] = @s3_server_side_encryption
            end
            write_options.merge!(@s3_headers)
            s3_object(style).write(file, write_options)
          rescue AWS::S3::Errors::NoSuchBucket => e
            create_bucket
            retry
          end
        end

        after_flush_writes # allows attachment to clean up temp files

        @queued_for_write = {}
      end
    end
  end
end