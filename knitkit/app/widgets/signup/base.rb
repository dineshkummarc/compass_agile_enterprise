
  module Widgets
    module Signup
      class Base < ErpApp::Widgets::Base
        def index
          render
        end

        def new
          @website = Website.find_by_host(request.host_with_port)
          @user = User.create(
            :first_name => params[:first_name],
            :last_name => params[:last_name],
            :email => params[:email],
            :login => params[:login],
            :password => params[:password],
            :password_confirmation => params[:password_confirmation]
          )
          if @user.valid?
            @user.activated_at = Time.now
            @user.roles << @website.role
            individual = Individual.create(:current_first_name => @user.first_name, :current_last_name => @user.last_name)
            @user.party = individual.party
            @user.save
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
            "Sign Up"
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

