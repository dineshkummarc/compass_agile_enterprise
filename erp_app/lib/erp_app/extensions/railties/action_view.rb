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

  def setup_role_manager(user)
    js_string = '<script type="text/javascript" src="/javascripts/erp_app/authentication/role_manager.js"></script>'
    js_string << "<script type='text/javascript'>ErpApp.Authentication.RoleManager.roles = [#{user.roles.collect{|role| "'#{role.internal_identifier}'"}.join(',')}];</script>"

    raw js_string
  end

  def include_code_mirror
    resources = ''

    resources << static_javascript_include_tag("/erp_app/codemirror/codemirror.js", "/erp_app/shared/compass_codemirror.js")
    
    raw resources
  end

  #active_ext helper methods
  def active_ext_close_button(options={})
    "<input type=\"button\" class=\"#{options[:class]}\" value=\"Close\" onclick=\"parent.Compass.ErpApp.Shared.ActiveExt.closeWindow('#{@model.class.to_s.underscore + "_" + @model.id.to_s}')\" />"
  end
end
