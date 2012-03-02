require 'fileutils'

module ErpApp
	module Desktop
		module FileManager
			class BaseController < ErpApp::Desktop::BaseController
			  
			  before_filter :set_file_support

        ROOT_NODE = 'root_node'

        def base_path
          @base_path ||= Rails.root.to_s
        end

        def update_file
          path    = params[:node]
          content = params[:content]

          @file_support.update_file(path, content)
          render :json => {:success => true}
        end

        def create_file
          path = (params[:path] == ROOT_NODE) ? base_path : params[:path]
          name = params[:name]

          @file_support.create_file(path, name, "#Empty File")
          render :json => {:success => true}
        end

        def create_folder
          path = (params[:path] == ROOT_NODE) ? base_path : params[:path]
          name = params[:name]

          @file_support.create_folder(path, name)
          render :json => {:success => true}
        end

        def download_file
          path = params[:path]

          contents, message = @file_support.get_contents(path)

          send_data contents, :filename => File.basename(path)
        end

        def save_move
          path            = params[:node]
          new_parent_path = (params[:parent_node] == ROOT_NODE) ? base_path : params[:parent_node]
          new_parent_path = File.join(root, new_parent_path)

          result, message = @file_support.save_move(path, new_parent_path)

          render :json => {:success => result, :msg => message}
        end

        def rename_file
          path = params[:node]
          name = params[:file_name]

          result, message = @file_support.rename_file(path, name)

          render :json => {:success => result, :msg => message}
        end

        def delete_file
          path = params[:node]

          result, message = @file_support.delete_file(path)

          render :json => {:success => result, :msg => message}
        end

        def expand_directory
          path = (params[:node] == ROOT_NODE) ? base_path : params[:node]

          render :json => @file_support.build_tree(path)
        end

        def get_contents
          path = params[:node]

          contents, message = @file_support.get_contents(path)

          if contents.nil?
            render :text => message
          else
            render :text => contents
          end
        end

        def upload_file
          if request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank?
            upload_path = params[:directory]
          else
            upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
          end

          upload_path = base_path if upload_path == ROOT_NODE

          result = upload_file_to_path(upload_path)

          render :inline => result.to_json
        end

        protected

        def upload_file_to_path(upload_path, valid_file_type_regex=nil)
          result = {}

          unless File.directory? upload_path
            FileUtils.mkdir_p(upload_path)
          end

          upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank? ? params[:directory] : request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
          name = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data].original_filename : request.env['HTTP_X_FILE_NAME']
          contents = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data] : request.raw_post

          if !valid_file_type_regex.nil? && name !=~ valid_file_type_regex
            result[:success] = false
            result[:error]   = "Invalid file type"
          elsif File.exists? "#{upload_path}/#{name}"
            result[:success] = false
            result[:error]   = "file #{name} already exists"
          else
            @file_support.create_file(upload_path, name, contents)
            result[:success] = true
          end

          result
        end

        def set_file_support
          @file_support = ErpTechSvcs::FileSupport::Base.new
        end
			
			end
		end
	end
end
