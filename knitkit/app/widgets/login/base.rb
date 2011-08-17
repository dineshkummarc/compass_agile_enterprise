
  module Widgets
    module Login
      class Base < ErpApp::Widgets::Base

        def index
          @logout_to  = params[:logout_to]
          @login_to   = params[:login_to]
          @signup_url = params[:signup_url]
    
          render
        end

        def login_header
          @login_url     = params[:login_url]
          @signup_url    = params[:signup_url]
          @authenticated = self.authenticated?
          if self.authenticated?
            @user = self.current_user
          end
    
          render
        end

        def new
          @login_to = params[:login_to]

          session[:logout_to] = params[:logout_to] unless params[:logout_to].blank?
          id = cookies[:remember_me_id]
          unless id.blank?
            u = User.find(id)
            unless u.nil?
              @login = u.login
            else
              @login = ""
            end
          end

          result = self.controller.password_authentication(params[:login], params[:password])

          if result
            render :view => :success
          else
            render :view => :error
          end
        end

        #should not be modified
        #modify at your own risk
        self.view_paths = File.join(File.dirname(__FILE__),"/views")
        
        def locate
          File.dirname(__FILE__)
        end
        
        class << self
          def title
            "Login"
          end
          
          def widget_name
            File.basename(File.dirname(__FILE__))
          end
          
          def base_layout
            begin
              file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
              IO.read(file)
            rescue
              return nil
            end
          end
        end
      end
    end
  end

