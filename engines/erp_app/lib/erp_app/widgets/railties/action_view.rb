ActionView::Base.class_eval do
  def render_widget(name, opts={})
    action = opts[:action] || :index
    params = opts[:params].nil? ? '{}' : opts[:params].to_json

    uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(100).to_s)

    "<div id='#{uuid}'><img src='/images/loading_icon.gif' alt='' />Loading Widget...</div><script type='text/javascript'>
      Compass.ErpApp.Widgets.setup('#{uuid}', '#{name}', '#{action}', #{params});
      Compass.ErpApp.Widgets.LoadedWidgets.push({id:'#{uuid}', name:'#{name}', action:'#{action}', params:#{params}});
     </script>"
  end

  def build_widget_url(action,id=nil)
    if id
      "/widgets/#{@widget_name}/#{action}/#{@uuid}/#{id}"
    else
      "/widgets/#{@widget_name}/#{action}/#{@uuid}"
    end
  end
  
  def widget_result_id
    "#{@uuid}_result"
  end

  def include_widget_javascript
    js = "<script type='text/javascript' src='/javascripts/erp_app/widgets.js' ></script>"
    js << ErpApp::Widgets::JavascriptLoader.glob_javascript
    js
  end

  def get_widget_action
    params[:widget_action] || 'index'
  end

  def set_widget_params(widget_params={})   
    widget_params.merge!(params.symbolize_keys)
    widget_params
  end

end
