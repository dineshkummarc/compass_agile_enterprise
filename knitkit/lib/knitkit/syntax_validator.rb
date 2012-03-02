module Knitkit
  class SyntaxValidator
    class << self

      def validate_content(file_type, content)
        case file_type.to_sym
        when :erb
          validate_erb(content)
        else
          return nil
        end
      end

      def validate_file(file)
        #stubbed for later development
      end

      private

      def validate_erb(contents)
        begin
          ActionView::Template::Handlers::Erubis.new(contents).result
        rescue SyntaxError=>ex
          ex.message
        rescue Exception=>ex
          nil
        end
      end

    end
  end#SyntaxValidator
end#Knitkit
