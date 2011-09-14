module Knitkit
  module ErpApp
    module Desktop
      class ThemeController < ::ErpApp::Desktop::FileManager::BaseController
        before_filter :set_website, :only => [:new, :change_status, :available_themes]
        before_filter :set_theme, :only => [:delete, :change_status, :copy]
        IGNORED_PARAMS = %w{action controller node_id theme_data}

        def index
          render :json => (params[:node] == ROOT_NODE) ? setup_tree : build_tree_for_directory(params[:node])
        end

        def available_themes
          result = {:success => true, :themes => []}
          @website.themes.each do |theme|
            result[:themes].push << {:id => theme.id, :name => theme.name}
          end
          render :json => result
        end

        def new
          unless params[:theme_data].blank?
            @website.themes.import(params[:theme_data], @website)
          else
            theme = Theme.create(:website => @website, :name => params[:name], :theme_id => params[:theme_id])
            params.each do |k,v|
              next if (k.to_s == 'name' or k.to_s == 'site_id' or k.to_s == 'theme_id')
              theme.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
            end
            theme.save
          end
          
          #issue with chrome and response headers leave it render :inline
          render :inline => {:success => true}.to_json
        end

        def delete
          @theme.destroy
          render :json => {:success => true}
        end

        def export
          theme = Theme.find(params[:id])
          zip_path = theme.export
          send_file(zip_path.to_s, :stream => false) rescue raise "Error sending #{zip_path} file"
        ensure
          FileUtils.rm_r File.dirname(zip_path) rescue nil
        end

        def change_status
          #clear active themes
          @website.deactivate_themes! if (params[:active] == 'true')

          (params[:active] == 'true') ? @theme.activate! : @theme.deactivate!
 
          render :json => {:success => true}
        end

        ##############################################################
        #
        # Overrides from ErpApp::Desktop::FileManager::BaseController
        #
        ##############################################################

        def create_file
          path = params[:path]
          name = params[:name]

          theme = get_theme(path)
          theme.add_file('#Empty File', File.join(path,name))

          render :json => {:success => true}
        end

        def upload_file
          result = {}
          
          upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank? ? params[:directory] : request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
          name = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data].original_filename : request.env['HTTP_X_FILE_NAME']          
          data = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data] : request.raw_post

          theme = get_theme(upload_path)
          begin
            theme.add_file(data, File.join(upload_path,name))
            result = {:success => true}
          rescue Exception=>ex
            logger.error ex.message
            logger.error ex.backtrace.join("\n")
            result = {:success => false, :error => "Error uploading #{name}"}
          end
          
          #the awesome uploader widget whats this to mime type text, leave it render :inline
          render :inline => result.to_json
        end
        
        def save_move
          result          = {}
          path            = params[:node]
          new_parent_path = params[:parent_node]
          new_parent_path = base_path if new_parent_path == ROOT_NODE

          unless File.exists? path
            result = {:success => false, :msg => 'File does not exists'}
          else
            theme_file = get_theme_file(path)
            theme_file.move(new_parent_path.gsub(Rails.root.to_s,''))
            result = {:success => true, :msg => "#{File.basename(path)} was moved to #{new_parent_path} successfully"}
          end

          render :json => result
			  end

        def delete_file
          path = params[:node]
          result = {}

          unless File.exists? path
            result = {:success => false, :error => "File does not exists"}
          else
            begin
              if File.directory? path
                result = Dir.entries(path) == [".", ".."] ? (FileUtils.rm_rf(path);{:success => true, :error => "Directory deleted."}) : {:success => false, :error => "Directory is not empty."}
              else
                name = File.basename(path)
                theme_file = get_theme_file(path)
                theme_file.destroy
                result = {:success => true, :error => "#{name} was deleted successfully"}
              end
            rescue Exception=>ex
              logger.error ex.message
              logger.error ex.backtrace.join("\n")
              result = {:success => false, :error => "Error deleting #{name}"}
            end

          end

          render :json => result
        end

        def rename_file
          result = {:success => true, :data => {:success => true}}
          path = params[:node]
          name = params[:file_name]

          unless File.exists? path
            result = {:success => false, :data => {:success => false, :error => 'File does not exists'}}
          else
            theme_file = get_theme_file(path)
            theme_file.rename(name)
          end

          render :json => result
        end

        private

        def get_theme(path)
          sites_index = path.index('sites')
          sites_path  = path[sites_index..path.length]
          site_name   = sites_path.split('/')[1]
          site        = Website.find(site_name.split('-')[1])

          themes_index = path.index('themes')
          path = path[themes_index..path.length]
          theme_name = path.split('/')[1]
          site.themes.find_by_theme_id(theme_name)
        end

        def get_theme_file(path)
          theme = get_theme(path)
          path = path.gsub!(Rails.root.to_s,'')
          theme.files.where('name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)).first
        end

        def setup_tree
          tree = []
          sites = Website.all
          sites.each do |site|
            site_hash = {
              :text => site.title,
              :browseable => true,
              :contextMenuDisabled => true,
              :iconCls => 'icon-globe',
              :id => "site_#{site.id}",
              :leaf => false,
              :children => []
            }

            #handle themes
            themes_hash = {:text => 'Themes', :contextMenuDisabled => true, :isThemeRoot => true, :siteId => site.id, :children => []}
            site.themes.each do |theme|
              theme_hash = {:text => "#{theme.name}[#{theme.theme_id}]", :handleContextMenu => true, :siteId => site.id, :isActive => (theme.active == 1), :isTheme => true, :id => theme.id, :children => []}
              if theme.active == 1
                theme_hash[:iconCls] = 'icon-add'
              else
                theme_hash[:iconCls] = 'icon-delete'
              end
              ['stylesheets', 'javascripts', 'images', 'templates'].each do |resource_folder|
                theme_hash[:children] << {:text => resource_folder, :leaf => false, :id => "#{theme.path}/#{resource_folder}"}
              end
              themes_hash[:children] << theme_hash
            end
            site_hash[:children] << themes_hash
            tree << site_hash
          end

          tree
        end

        protected

        def set_website
          @website = Website.find(params[:site_id])
        end

        def set_theme
          @theme = Theme.find(params[:id])
        end
  
      end
    end
  end
end
