module ErpApp
  module Widgets
    class JavascriptLoader

      def self.glob_javascript
        files = Rails.application.config.erp_app.widgets.collect{|widget|Dir.glob(File.join(widget[:path],"javascript/*.js"))}.flatten
        
        "<script type='text/javascript'>#{Uglifier.compile(files.collect{|file| IO.read(file)}.join(''))}</script>"
      end

    end#JavascriptLoader
  end#Widgets
end#ErpApp
