
module Widgets
  module Signup
    class Base < ErpApp::Widgets::Base
      def index
        @login_url = params[:login_url]
        render
      end

      def new
        @website = Website.find_by_host(request.host_with_port)
        @configuration = @website.configurations.first
        password_config_option = @configuration.get_item(ConfigurationItemType.find_by_internal_identifier('password_strength_regex')).options.first
        @email = params[:email]
        @user = User.new(
          :email => @email,
          :username => params[:username],
          :password => params[:password],
          :password_confirmation => params[:password_confirmation]
        )
        @user.password_validator = {:regex => password_config_option.value, :error_message => password_config_option.comment}
        #set this to tell activation where to redirect_to for login and temp password
        @user.add_instance_attribute(:login_url,params[:login_url])
        @user.add_instance_attribute(:temp_password, params[:password])
        @user.add_instance_attribute(:domain, @website.hosts.first.host)
        begin
          if @user.save
            @user.roles << @website.role
            individual = Individual.create(:current_first_name => params[:first_name], :current_last_name => params[:last_name])
            @user.party = individual.party
            @user.save
            render :update => {:id => "#{@uuid}_result", :view => :success}
          else
            render :update => {:id => "#{@uuid}_result", :view => :error}
          end
        rescue Exception=>ex
          logger.error ex.message
          logger.error ex.backtrace
          render :update => {:id => "#{@uuid}_result", :view => :error}
        end
      end

      #should not be modified
      #modify at your own risk
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

