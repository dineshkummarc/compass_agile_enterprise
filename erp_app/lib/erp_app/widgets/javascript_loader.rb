class ErpApp::Widgets::JavascriptLoader
  def self.glob_javascript
    dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}

    files = []
    dirs.each do |engine_dir|
      files = files | Dir.glob(File.join(engine_dir,"/lib/erp_app/widgets/*/javascript/*.js"))
    end

    js_code = '<script type="text/javascript">'
    files.each do |file|
      js_code <<  IO.read(file)
    end
    js_code << '</script>'

    js_code
  end

end
