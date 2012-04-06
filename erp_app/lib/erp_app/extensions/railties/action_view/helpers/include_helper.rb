module ErpApp
  module Extensions
    module Railties
      module ActionView
        module Helpers
          module IncludeHelper

            def static_javascript_include_tag(*srcs)
              raw srcs.flatten.map{|src| "<script type=\"text/javascript\" src=\"/javascripts/#{src}\"></script>"}.join("")
            end
      
            def static_stylesheet_link_tag(*srcs)
              raw srcs.flatten.map{|src| "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheets/#{src}\" />"}.join("")
            end
      
            def set_max_file_upload
              raw "<script type='text/javascript'>Ext.ns('ErpApp.FileUpload'); ErpApp.FileUpload.maxSize = #{Rails.application.config.erp_tech_svcs.max_file_size_in_mb.megabytes};</script>"
            end

            def include_extjs(opt={})
              resources = ''

              if opt[:debug] or Rails.env != 'production'
                resources << static_javascript_include_tag("extjs/ext-all-debug.js")
              else
                resources << static_javascript_include_tag("extjs/ext-all.js")
              end

              resources << static_javascript_include_tag("extjs/ext_ux_tab_close_menu.js")
              resources << static_javascript_include_tag("extjs/Ext.ux.form.MultiSelect.js")

              if opt[:theme] === false
                #do nothing not theme loaded.
              elsif opt[:theme]
                resources << static_stylesheet_link_tag("extjs/resources/css/#{opt[:theme]}")
              else
                resources << static_stylesheet_link_tag("extjs/resources/css/ext-all.css")
              end
        
              raw resources
            end

            def include_sencha_touch(opt={})
              resources = ''

              if(opt[:debug])
                resources << static_javascript_include_tag("extjs/sencha-touch-debug.js")
              else
                resources << static_javascript_include_tag("extjs/sencha-touch.js")
              end

              if opt[:theme] === false
                #do nothing not theme loaded.
              elsif opt[:theme]
                resources << static_stylesheet_link_tag("extjs/sench_touch/resources/css/#{opt[:theme]}")
              else
                resources << static_stylesheet_link_tag("extjs/sench_touch/resources/css/sencha-touch.css")
                resources << static_stylesheet_link_tag("extjs/sench_touch/resources/css/apple.css")
              end

              raw resources
            end
      
            def include_highslide( options = {} )
              raw case options[:version].to_s.downcase
              when 'full'
                static_javascript_include_tag("erp_app/highslide/highslide/highslide-full.js")
              when 'gallery'
                static_javascript_include_tag("erp_app/highslide/highslide/highslide-with-gallery.js")
              when 'html'
                static_javascript_include_tag("erp_app/highslide/highslide/highslide-with-html.js")
              else
                static_javascript_include_tag("erp_app/highslide/highslide/highslide.js")
              end
            end

            def setup_js_authentication(user, app_container)
              current_user = {
                :username => user.username,
                :lastloginAt => user.last_login_at,
                :lastActivityAt => user.last_activity_at,
                :failedLoginCount =>  user.failed_logins_count,
                :email => user.email,
                :roles => user.roles.collect{|role| role.internal_identifier},
                :id => user.id,
                :description => user.party.to_s
              }
              js_string = static_javascript_include_tag('erp_app/authentication/compass_user.js', 'erp_app/authentication/widget_manager.js')
              js_string << (raw "<script type='text/javascript'>var applicationRoleManager = new ErpApp.CompassAccessNegotiator.ApplicationRoleManager(#{app_container.applications.collect{|application| application.to_access_hash}.to_json});var currentUser = new ErpApp.CompassAccessNegotiator.CompassUser(#{current_user.to_json}, applicationRoleManager);</script>")
              js_string
            end

            def include_code_mirror_library
              resources = static_javascript_include_tag("erp_app/codemirror/lib/codemirror.js")
              resources << (raw "<link rel=\"stylesheet\" type=\"text/css\" href=\"/javascripts/erp_app/codemirror/lib/codemirror.css\" />")
              resources << (raw "<link rel=\"stylesheet\" type=\"text/css\" href=\"/javascripts/erp_app/codemirror/theme/default.css\" />")
              resources
            end
      
            def include_compass_ae_instance_about
              compass_ae_instance = CompassAeInstance.first
              json_hash = {
                :version => compass_ae_instance.version,
                :installedAt => compass_ae_instance.created_at.strftime("%B %d, %Y at %I:%M%p"),
                :lastUpdateAt => compass_ae_instance.updated_at.strftime("%B %d, %Y at %I:%M%p"),
                :installedEngines => compass_ae_instance.installed_engines
              }
              raw "<script type=\"text/javascript\">var compassAeInstance = #{json_hash.to_json};</script>"
            end

            def add_authenticity_token_to_extjs
              raw "<script type='text/javascript'>Ext.Ajax.extraParams = { authenticity_token: '#{form_authenticity_token}' }; Compass.ErpApp.AuthentictyToken = '#{form_authenticity_token}';</script>"
            end

            def load_shared_application_resources(resource_type)
              resource_type = resource_type.to_sym
              case resource_type
              when :javascripts
                raw static_javascript_include_tag(ErpApp::ApplicationResourceLoader::SharedLoader.new.locate_shared_files(resource_type))
              when :stylesheets
                raw static_stylesheet_link_tag(ErpApp::ApplicationResourceLoader::SharedLoader.new.locate_shared_files(resource_type))
              end
            end

          end#IncludeHelper
        end#Helpers
      end#ActionView
    end#Railties
  end#Extensions
end#ErpApp