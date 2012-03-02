ActionView::Base.class_eval do
  def render_widget(name, opts={})
    action = opts[:action] || :index
    params = opts[:params].nil? ? '{}' : opts[:params].to_json

    uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)

    raw "<div id='#{uuid}'>Loading Widget...<script type='text/javascript'>Compass.ErpApp.Widgets.setup('#{uuid}', '#{name}', '#{action}', #{params}, true);</script></div>"
  end

  def build_widget_url(action,id=nil)
    if id
      "/erp_app/widgets/#{@name}/#{action}/#{@uuid}/#{id}"
    else
      "/erp_app/widgets/#{@name}/#{action}/#{@uuid}"
    end
  end
  
  def widget_result_id
    "#{@uuid}_result"
  end

  def include_widgets
    raw ErpApp::Widgets::JavascriptLoader.glob_javascript
  end

  def get_widget_action
    params[:widget_action] || 'index'
  end

  def set_widget_params(widget_params={})   
    widget_params.merge!(params.symbolize_keys)
    widget_params
  end

end