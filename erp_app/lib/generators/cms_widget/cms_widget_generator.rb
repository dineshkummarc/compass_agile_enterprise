class CmsWidgetGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :description, :type => :string 
  argument :icon_url, :type => :string
  
  def generate_widget
    #engine
    template "engine/engine_template.rb", "app/widgets/#{file_name}/base.rb"
    
    #javascript
    template "javascript/base.js.erb", "app/widgets/#{file_name}/javascript/#{file_name}.js"
    
    #views
    template "views/index.html.erb", "app/widgets/#{file_name}/views/index.html.erb"
  end
  
end
