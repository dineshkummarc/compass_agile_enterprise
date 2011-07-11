class ErpApp::Widgets::JavascriptLoader
  def self.glob_javascript
    plugin_names = Rails.plugins.collect{|item| item.first}

    files = []
    plugin_names.each do |plugin_name|
      files = files | Dir.glob(File.join(Rails.root,"/vendor/plugins/#{plugin_name.to_s}/lib/erp_app/widgets/*/javascript/*.js"))
    end

    js_code = '<script type="text/javascript">'
    files.each do |file|
      js_code <<  IO.read(file)
    end
    js_code << '</script>'

    js_code
  end

end
