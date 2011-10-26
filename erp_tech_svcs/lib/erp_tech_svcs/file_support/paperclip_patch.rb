module Paperclip
  module Storage
    module S3
      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          begin
            log("saving #{path(style)}")
            AWS::S3::S3Object.store(path(style),
              file,
              bucket_name,
              {:content_type => content_type,
                :access => (@s3_permissions[style] || @s3_permissions[:default]),
              }.merge(@s3_headers))
          rescue AWS::S3::NoSuchBucket => e
            create_bucket
            retry
          rescue AWS::S3::ResponseError => e
            raise
          end
        end

        after_flush_writes # allows attachment to clean up temp files

        @queued_for_write = {}
      end
    end
  end
end