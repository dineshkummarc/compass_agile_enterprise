ActionView::Base.class_eval do
  def static_javascript_include_tag(*srcs)
    raw srcs.map{|src| "<script type=\"text/javascript\" src=\"/javascripts/#{src}\"></script>"}.join(" ")
  end
  
  def static_stylesheet_link_tag(*srcs)
    raw srcs.map{|src| "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheets/#{src}\" />"}.join(" ")
  end
  
  def include_file_upload()
    resources = ''

    resources << static_javascript_include_tag("erp_app/shared/file_upload/Ext.ux.AwesomeUploader.js",
      "erp_app/shared/file_upload/Ext.ux.AwesomeUploaderLocalization.js",
      "erp_app/shared/file_upload/Ext.ux.XHRUpload.js",
      "erp_app/shared/file_upload/upload_window.js"
    )

    resources << static_stylesheet_link_tag("erp_app/shared/file_upload/AwesomeUploader.css")

    raw resources
  end

  def include_extjs(opt={})
    resources = ''

    if(opt[:debug])
      resources << static_javascript_include_tag("extjs/ext-all-debug.js")
    else
      resources << static_javascript_include_tag("extjs/ext-all.js")
    end

    if opt[:theme] === false
      #do nothing not theme loaded.
    elsif opt[:theme]
      resources << static_stylesheet_link_tag("extjs/resources/css/#{opt[:theme]}")
    else
      resources << static_stylesheet_link_tag("extjs/resources/css/ext-all.css")
    end
    
    raw resources
  end
  
  def include_highslide( options = {} )
    raw case options[:version].to_s.downcase
    when 'full'
      static_javascript_include_tag("/erp_app/highslide/highslide/highslide-full.js")
    when 'gallery'
      static_javascript_include_tag("/erp_app/highslide/highslide/highslide-with-gallery.js")
    when 'html'
      static_javascript_include_tag("/erp_app/highslide/highslide/highslide-with-html.js")
    else
      static_javascript_include_tag("/erp_app/highslide/highslide/highslide.js")
    end
  end

  def setup_js_authentication(user)
    current_user = {:username => user.username, :lastSignInAt => user.last_sign_in_at, :email => user.email, :id => user.id}
    js_string = '<script type="text/javascript" src="/javascripts/erp_app/authentication/role_manager.js"></script>'
    js_string << "<script type='text/javascript'>ErpApp.Authentication.currentUser = #{current_user.to_json};ErpApp.Authentication.RoleManager.roles = [#{user.roles.collect{|role| "'#{role.internal_identifier}'"}.join(',')}];</script>"

    raw js_string
  end

  def include_code_mirror
    resources = ''

    resources << static_javascript_include_tag("erp_app/codemirror/lib/codemirror.js", 
                                               "erp_app/shared/compass_codemirror.js")
    resources << "<link rel=\"stylesheet\" type=\"text/css\" href=\"/javascripts/erp_app/codemirror/lib/codemirror.css\" />"
    resources << "<link rel=\"stylesheet\" type=\"text/css\" href=\"/javascripts/erp_app/codemirror/theme/default.css\" />"
    
    raw resources
  end

  #active_ext helper methods
  def active_ext_close_button(options={})
    raw "<input type=\"button\" class=\"#{options[:class]}\" value=\"Close\" onclick=\"parent.Compass.ErpApp.Shared.ActiveExt.closeWindow('#{@model.class.to_s.underscore + "_" + @model.id.to_s}')\" />"
  end
  
  def link_to_remote(name, url, options={})
    options.merge!({:class => 'ajax_replace', :remote => true})
    link_to name, url, options
  end
  
  def form_remote_tag(url, options={}, &block)
    options.merge!({:class => 'ajax_replace', :remote => true})
    form_tag url, options do
      yield
    end
  end
  
end
