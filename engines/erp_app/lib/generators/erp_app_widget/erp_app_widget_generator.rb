class ErpAppWidgetGenerator < Rails::Generator::NamedBase
  @icon_url = nil
  @description = nil
  @plugin = nil

  def initialize(runtime_args, runtime_options = {})
    super
    raise "Must Include A Description For This Widget" if runtime_args[1].blank?
    raise "Must Include An Icon Url For This Widget" if runtime_args[2].blank?
    @description      = runtime_args[1]
    @icon_url         = runtime_args[2]
    @plugin = runtime_args[3].blank? ? 'erp_app' : runtime_args[3]
  end

  def manifest
    record do |m|

      m.directory "vendor/plugins/#{@plugin}/lib/erp_app/widgets/#{file_name}"
      
      #engine
      m.template "engine/engine_template.rb", "vendor/plugins/#{@plugin}/lib/erp_app/widgets/#{file_name}/base.rb"

      #javascript
      m.directory "vendor/plugins/#{@plugin}/lib/erp_app/widgets/#{file_name}/javascript"
      m.template "javascript/base.js.erb", "vendor/plugins/#{@plugin}/lib/erp_app/widgets/#{file_name}/javascript/#{file_name}.js"

      #views
      m.directory "vendor/plugins/#{@plugin}/lib/erp_app/widgets/#{file_name}/views"
      m.template "views/index.html.erb", "vendor/plugins/#{@plugin}/lib/erp_app/widgets/#{file_name}/views/index.html.erb"

      #Readme
      m.readme "INSTALL"
    end
  end

  def description
    @description
  end

  def icon_url
    @icon_url
  end

  def in_erp_app?
    @plugin == 'erp_app'
  end
end
