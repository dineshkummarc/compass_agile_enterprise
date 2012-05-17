module Knitkit
  module ErpApp
    module Desktop
      class ThemeController < ::ErpApp::Desktop::FileManager::BaseController
        before_filter :set_file_support
        before_filter :set_website, :only => [:new, :change_status, :available_themes]
        before_filter :set_theme, :only => [:delete, :change_status, :theme_widget, :available_widgets]
        IGNORED_PARAMS = %w{action controller node_id theme_data}

        def index
          if params[:node] == ROOT_NODE
            setup_tree
          else
            theme = get_theme(params[:node])
            unless theme.nil?
              render :json => @file_support.build_tree(params[:node], :file_asset_holder => theme, :preload => true)
            else
              render :json => {:success => false, :message => 'Could not find theme'}
            end
          end
        end

        def available_themes
          render :json => {:success => true, :themes => @website.themes.map{|theme|{:id => theme.id, :name => theme.name}}}
        end

        def available_widgets
          render :json => {:success => true, :widgets => @theme.non_themed_widgets.map{|widget|{:id => widget, :name => widget.humanize}}}
        end

        def theme_widget
          @theme.create_layouts_for_widget(params[:widget_id])
          render :json => {:success => true}
        end

        def new
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              unless params[:theme_data].blank?
                @website.themes.import(params[:theme_data], @website)
              else
                theme = Theme.create(:website => @website, :name => params[:name], :theme_id => params[:theme_id])
                theme.version  = params[:version]
                theme.author   = params[:author]
                theme.homepage = params[:homepage]
                theme.summary  = params[:summary]
                theme.save
                theme.create_theme_files!
              end

              render :inline => {:success => true}.to_json
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def delete
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              if @theme.destroy
                #clear resolver cache
                path = File.join("#{@theme[:url]}","templates")
                cached_resolver = ThemeSupport::Cache.theme_resolvers.find{|cached_resolver| cached_resolver.to_path == path}
                render :json => {:success => true}
              else
                render :json =>  {:success => false}
              end
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def export
          theme = Theme.find(params[:id])
          zip_path = theme.export
          send_file(zip_path.to_s, :stream => false) rescue raise "Error sending #{zip_path} file"
        ensure
          FileUtils.rm_r File.dirname(zip_path) rescue nil
        end

        def change_status
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              #clear active themes
              @website.deactivate_themes! if (params[:active] == 'true')
              (params[:active] == 'true') ? @theme.activate! : @theme.deactivate!

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        ##############################################################
        #
        # Overrides from ErpApp::Desktop::FileManager::BaseController
        #
        ##############################################################

        def create_file
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              path = File.join(@file_support.root,params[:path])
              name = params[:name]

              theme = get_theme(path)
              theme.add_file('#Empty File', File.join(path, name))

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def create_folder
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              path = File.join(@file_support.root,params[:path])
              name = params[:name]

              @file_support.create_folder(path, name)
              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update_file
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              path = File.join(@file_support.root,params[:node])
              content = params[:content]

              type = File.extname(File.basename(path)).gsub(/^\.+/, '').to_sym
              result = Knitkit::SyntaxValidator.validate_content(type, content)

              unless result
                @file_support.update_file(path, content)
                render :json => {:success => true}
              else
                render :json => {:success => false, :message => result}
              end
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def save_move
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              result          = {}
              path            = File.join(@file_support.root, params[:node])
              new_parent_path = File.join(@file_support.root, params[:parent_node])

              unless @file_support.exists? path
                result = {:success => false, :msg => 'File does not exist.'}
              else
                theme_file = get_theme_file(path)
                theme_file.move(params[:parent_node])
                result = {:success => true, :msg => "#{File.basename(path)} was moved to #{new_parent_path} successfully"}
              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def download_file
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              path = File.join(@file_support.root,params[:path])
              contents, message = @file_support.get_contents(path)

              send_data contents, :filename => File.basename(path)
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def get_contents
          path = File.join(@file_support.root,params[:node])
          contents, message = @file_support.get_contents(path)

          if contents.nil?
            render :text => message
          else
            render :text => contents
          end
        end

        def upload_file
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              result = {}
              upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank? ? params[:directory] : request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
              name = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data].original_filename : request.env['HTTP_X_FILE_NAME']
              data = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data] : request.raw_post

              theme = get_theme(upload_path)
              name = File.join(@file_support.root, upload_path, name)

              begin
                theme.add_file(data, name)
                result = {:success => true}
              rescue Exception=>ex
                logger.error ex.message
                logger.error ex.backtrace.join("\n")
                result = {:success => false, :error => "Error uploading #{name}"}
              end

              render :inline => result.to_json
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def delete_file
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              path = params[:node]
              result = {}
              begin
                name = File.basename(path)
                result, message, is_folder = @file_support.delete_file(File.join(@file_support.root,path))
                if result && !is_folder
                  theme_file = get_theme_file(path)
                  theme_file.destroy
                  #clear resolver cache
                  path = File.join("#{@theme[:url]}","templates")
                  cached_resolver = ThemeSupport::Cache.theme_resolvers.find{|cached_resolver| cached_resolver.to_path == path}
                end
                result = {:success => result, :error => message}
              rescue Exception=>ex
                logger.error ex.message
                logger.error ex.backtrace.join("\n")
                result = {:success => false, :error => "Error deleting #{name}"}
              end
              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def rename_file
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'view', 'Theme') do
              result = {:success => true, :data => {:success => true}}
              path = params[:node]
              name = params[:file_name]

              result, message = @file_support.rename_file(@file_support.root+path, name)
              if result
                theme_file = get_theme_file(path)
                theme_file.name = name
                theme_file.save
              end

              render :json =>  {:success => true, :message => message}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        protected

        def get_theme(path)
          sites_index = path.index('sites')
          sites_path  = path[sites_index..path.length]
          site_name   = sites_path.split('/')[1]
          site        = Website.find_by_internal_identifier(site_name)

          themes_index = path.index('themes')
          path = path[themes_index..path.length]
          theme_name = path.split('/')[1]
          @theme = site.themes.find_by_theme_id(theme_name)

          @theme
        end

        def get_theme_file(path)
          theme = get_theme(path)
          file_dir = ::File.dirname(path).gsub(Regexp.new(Rails.root.to_s), '')
          theme.files.where('name = ? and directory = ?', ::File.basename(path), file_dir).first
        end

        def setup_tree
          tree = []
          sites = Website.all
          sites.each do |site|
            site_hash = {
              :text => site.name,
              :browseable => true,
              :contextMenuDisabled => true,
              :iconCls => 'icon-globe',
              :id => "site_#{site.id}",
              :leaf => false,
              :children => []
            }

            #handle themes
            themes_hash = {:text => 'Themes', :contextMenuDisabled => true, :iconCls => 'icon-content', :isThemeRoot => true, :siteId => site.id, :children => []}
            site.themes.each do |theme|
              theme_hash = {:text => "#{theme.name}[#{theme.theme_id}]", :handleContextMenu => true, :siteId => site.id, :isActive => (theme.active == 1), :iconCls => 'icon-content', :isTheme => true, :id => theme.id, :children => []}
              if theme.active == 1
                theme_hash[:iconCls] = 'icon-add'
              else
                theme_hash[:iconCls] = 'icon-delete'
              end
              ['stylesheets', 'javascripts', 'images', 'templates', 'widgets'].each do |resource_folder|
                theme_hash[:children] << {:text => resource_folder, :iconCls => 'icon-content', :id => "#{theme.url}/#{resource_folder}"}
              end
              themes_hash[:children] << theme_hash
            end
            site_hash[:children] << themes_hash
            tree << site_hash
          end

          render :json => tree
        end

        def set_website
          @website = Website.find(params[:site_id])
        end

        def set_theme
          @theme = Theme.find(params[:theme_id])
        end

        def set_file_support
          @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::Config.file_storage)
        end
  
      end#ThemeController
    end#Desktop
  end#ErpApp
end#Knitkit
