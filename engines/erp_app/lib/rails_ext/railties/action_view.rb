ActionView::Base.class_eval do
  def include_file_upload()
    resources = ''

    resources << javascript_include_tag("/javascripts/erp_app/shared/file_upload/Ext.ux.AwesomeUploader.js",
      "/javascripts/erp_app/shared/file_upload/Ext.ux.AwesomeUploaderLocalization.js",
      "/javascripts/erp_app/shared/file_upload/Ext.ux.XHRUpload.js",
      "/javascripts/erp_app/shared/file_upload/Ext.ux.form.FileUploadField.js",
      "/javascripts/erp_app/shared/file_upload/upload_window.js"
    )

    resources
  end

  def include_extjs(version='ext', theme=nil)
    resources = ''

    if Rails.env == 'development'
      resources << javascript_include_tag("/javascripts/#{version}/adapter/ext/ext-base-debug.js","#{version}/ext-all-debug.js")
    else
      resources << javascript_include_tag("/javascripts/#{version}/adapter/ext/ext-base.js","#{version}/ext-all.js")
    end

    resources << stylesheet_link_tag("/stylesheets/#{version}/resources/css/ext-all.css")

    unless theme.nil?
      resources << stylesheet_link_tag('/stylesheets/ext/resources/css/xtheme-slate.css')
    end

    resources
  end

  def setup_role_manager(user)
    roles = user.roles
    "<script type='text/javascript'>ErpApp.Authentication.RoleManager.roles = [#{roles.collect{|role| "'#{role.internal_identifier}'"}.join(',')}];</script>"
  end

  def include_code_mirror
    resources = ''

    resources << javascript_include_tag("/javascripts/erp_app/codemirror/codemirror.js", "/javascripts/erp_app/shared/compass_codemirror.js")
    

    resources
  end

  #active_ext helper methods

  def active_ext_close_button(options={})
    "<input type=\"button\" class=\"#{options[:class]}\" value=\"Close\" onclick=\"parent.Compass.ErpApp.Shared.ActiveExt.closeWindow('#{@model.class.to_s.underscore + "_" + @model.id.to_s}')\" />"
  end
end
