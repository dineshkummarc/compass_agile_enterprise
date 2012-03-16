module Knitkit
  module ErpApp
    module Desktop
      class WebsiteController < Knitkit::ErpApp::Desktop::AppController
        IGNORED_PARAMS = %w{action controller id}

        before_filter :set_website, :only => [:export, :website_publications, :set_viewing_version, :activate_publication, :publish, :update, :delete]
  
        def index
          render :json => {:sites => Website.all}
        end

        def website_publications
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'version'
          dir  = sort_hash[:direction] || 'DESC'
          limit = params[:limit] || 9
          start = params[:start] || 0
    
          published_websites = @website.published_websites.order("#{sort} #{dir}").limit(limit).offset(start)
    
          #set site_version. User can view different versions. Check if they are viewing another version
          site_version = @website.active_publication.version
          if !session[:website_version].blank? && !session[:website_version].empty?
            site_version_hash = session[:website_version].find{|item| item[:website_id] == @website.id}
            site_version = site_version_hash[:version].to_f unless site_version_hash.nil?
          end

          PublishedWebsite.class_exec(site_version) do
            cattr_accessor :site_version
            self.site_version = site_version
            def viewing
              self.version == self.site_version
            end
          end

          render :inline => "{\"success\":true, \"results\":#{published_websites.count},
                            \"totalCount\":#{@website.published_websites.count},
                            \"data\":#{published_websites.to_json(
          :only => [:comment, :id, :version, :created_at, :active],
          :methods => [:viewing, :published_by_username])} }"
        end

        def activate_publication
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'activate', 'Website') do
              @website.set_publication_version(params[:version].to_f, current_user)

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def set_viewing_version
          if session[:website_version].blank?
            session[:website_version] = []
            session[:website_version] << {:website_id => @website.id, :version => params[:version]}
          else
            session[:website_version].delete_if{|item| item[:website_id] == @website.id}
            session[:website_version] << {:website_id => @website.id, :version => params[:version]}
          end

          render :json => {:success => true}
        end

        def publish
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'publish', 'Website') do
              @website.publish(params[:comment], current_user)

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def new
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'create', 'Website') do
              result = {}
              website = Website.new
              website.subtitle                  = params[:subtitle]
              website.title                     = params[:title]
              website.name                      = params[:name]
              website.email                     = params[:email]
              website.auto_activate_publication = params[:auto_activate_publication] == 'yes'
              website.email_inquiries           = params[:email_inquiries] == 'yes'

              # create homepage
              website_section = WebsiteSection.new
              website_section.title = "Home"
              website_section.in_menu = true
              website.website_sections << website_section
              if website.save
                website.setup_default_pages

                #set default publication published by user
                first_publication = website.published_websites.first
                first_publication.published_by = current_user
                first_publication.save

                website.hosts << WebsiteHost.create(:host => params[:host])
                website.configurations.first.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('primary_host'), params[:host])
                website.save

                website.publish("Publish Default Sections", current_user)
                PublishedWebsite.activate(website, 1, current_user)
      
                result[:success] = true
              else
                result[:success] = false
              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit', 'Website') do
              @website.email                     = params[:email]
              @website.name                      = params[:name]
              @website.title                     = params[:title]
              @website.subtitle                  = params[:subtitle]
              @website.auto_activate_publication = params[:auto_activate_publication] == 'yes'
              @website.email_inquiries           = params[:email_inquiries] == 'yes'

              render :json => @website.save ? {:success => true} : {:success => false}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end
  
 
        def delete
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'delete', 'Website') do
              render :json => @website.destroy ? {:success => true} : {:success => false}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def export
          zip_path = @website.export
          send_file(zip_path.to_s, :stream => false) rescue raise "Error sending #{zip_path} file"
        ensure
          FileUtils.rm_r File.dirname(zip_path) rescue nil
        end

        # TODO add role restriction to this
        def import
          result, message = Website.import(params[:website_data], current_user)

          render :inline => {:success => result, :message => message}.to_json
        ensure
          FileUtils.rm_r File.dirname(zip_path) rescue nil
        end

        def add_host
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'create', 'Host') do
              website = Website.find(params[:id])
              website_host = WebsiteHost.create(:host => params[:host])
              website.hosts << website_host
              website.save

              render :json => {
                :success => true,
                :node => {
                  :text => website_host.attributes['host'],
                  :websiteHostId => website_host.id,
                  :host => website_host.attributes['host'],
                  :iconCls => 'icon-globe',
                  :url => "http://#{website_host.attributes['host']}",
                  :isHost => true,
                  :leaf => true,
                  :children => []}
              }
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update_host
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit', 'Host') do
              website_host = WebsiteHost.find(params[:id])
              website_host.host = params[:host]
              website_host.save

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def delete_host
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'delete', 'Host') do
              render :json => WebsiteHost.destroy(params[:id]) ? {:success => true} : {:success => false}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        protected

        def set_website
          @website = Website.find(params[:id])
        end
  
      end#WebsiteController
    end#Desktop
  end#ErpApp
end#Knitkit
