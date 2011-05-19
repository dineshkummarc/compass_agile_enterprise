ActionView::Base.class_eval do
  def render_widget(name, opts={})
    id = "#{Digest::SHA1.hexdigest Time.now.to_s}_#{name}"

    action = opts[:action] || :index
    params = opts[:params].nil? ? '{}' : opts[:params].to_json

    "<div id='#{id}'></div><script type='text/javascript'>Compass.ErpApp.Widgets.setup('#{id}', '#{name}', '#{action}', #{params})</script>"
  end

  def build_widget_url(action)
    "/widgets/#{@widget_name}/#{action}"
  end

  def include_widget_javascript
    ErpApp::Widgets::JavascriptLoader.glob_javascript
  end

end
