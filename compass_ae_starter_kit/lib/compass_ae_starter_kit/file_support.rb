module CompassAeStarterKit
  class FileSupport
    class << self

      def patch_file(path, current, insert, options = {})
        options = {
          :patch_mode => :insert_after
        }.merge(options)

        old_text = current
        new_text = patch_string(current, insert, options[:patch_mode])

        content = File.open(path) { |f| f.read }
        content.gsub!(old_text, new_text) unless content =~ /#{Regexp.escape(insert)}/mi
        File.open(path, 'w') { |f| f.puts(content) }
      end

      def append_file(path, content)
        File.open(path, 'a') { |f| f.puts(content) }
      end

      def patch_string(current, insert, mode = :insert_after)
        case mode
        when :change
          "#{insert}"
        when :insert_after
          "#{current}\n#{insert}"
        when :insert_before
          "#{insert}\n#{current}"
        else
          patch_string(current, insert, :insert_after)
        end
      end
      
    end
  end
end