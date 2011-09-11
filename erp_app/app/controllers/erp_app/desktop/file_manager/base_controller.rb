require 'fileutils'

module ErpApp
	module Desktop
		module FileManager
			class BaseController < ErpApp::Desktop::BaseController
			  REMOVE_FILES_REGEX = /^\./
			  ROOT_NODE = 'root_node'

			  def base_path
          @base_path ||= Rails.root.to_s
			  end

			  def update_file
          path     = params[:node]
          content = params[:content]

          File.open(path, 'w+') {|f| f.write(content) }

          render :json => {:success => true}
			  end

			  def create_file
          path = params[:path]
          name = params[:name]

          path = base_path if path == ROOT_NODE

          FileUtils.mkdir_p path unless File.exists? path

          File.open(File.join(path,name), 'w+') {|f| f.write('') }

          render :json => {:success => true}
			  end

			  def create_folder
          path = params[:path]
          name = params[:name]

          path = base_path if path == ROOT_NODE

          FileUtils.mkdir_p File.join(path,name)

          render :json => {:success => true}
			  end

			  def download_file
          path = params[:path]

          send_file path, :type => "text/plain"
			  end

			  def save_move
          result          = {}
          path            = params[:node]
          new_parent_path = params[:parent_node]

          new_parent_path = base_path if new_parent_path == ROOT_NODE

          unless File.exists? path
            result = {:success => false, :msg => 'File does not exists'}
          else
            name = File.basename(path)
            #make sure path is there.
            FileUtils.mkdir_p new_parent_path unless File.directory? new_parent_path
            FileUtils.mv(path, new_parent_path + '/' + name)
            result = {:success => true, :msg => "#{name} was moved to #{new_parent_path} successfully"}
          end

          render :json => result
			  end

			  def rename_file
          result = {}
          path   = params[:node]
          name   = params[:file_name]

          unless File.exists? path
            result = {:success => false, :msg => 'File does not exists'}
          else
            old_name = File.basename(path)
            path_pieces = path.split('/')
            path_pieces.delete(path_pieces.last)
            path_pieces.push(name)
            new_path = path_pieces.join('/')
            File.rename(path, new_path)
            result = {:success => true, :msg => "#{old_name} was renamed to #{name} successfully"}
          end

          render :json => result
			  end

			  def delete_file
          result = {}
          path = params[:node]

          unless File.exists? path
            result = {:success => false, :msg => 'File does not exists'}
          else
            name = File.basename(path)
            FileUtils.rm_rf(path)
            result = {:success => true, :msg => "#{name} was deleted successfully"}
          end

          render :json => result
			  end

			  def upload_file
          upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank? ? params[:directory] : request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']

          upload_path = base_path if upload_path == ROOT_NODE

          result = upload_file_to_path(upload_path)
          
          #the awesome uploader widget whats this to mime type text, leave it render :inline
          render :inline => result.to_json
			  end

			  def expand_directory
          expand_file_directory(params[:node])
			  end

			  def get_contents
          contents = ''
          path = params[:node]
          contents = IO.read(path) unless path == ROOT_NODE
          render :text => contents
			  end

			  protected

			  def upload_file_to_path(upload_path, valid_file_type_regex=nil)
          result = {}

          FileUtils.mkdir_p(upload_path) unless File.directory? upload_path

          unless request.env['HTTP_X_FILE_NAME'].blank?
            contents = request.raw_post
            name     = request.env['HTTP_X_FILE_NAME']
          else
            file_contents = params[:file_data]
            name = file_contents.original_filename
            contents = file_contents.respond_to?(:read) ? file_contents.read : File.read(file_contents.path)
          end

          if !valid_file_type_regex.nil? && name !=~ valid_file_type_regex
            result[:success] = false
            result[:error]   = "Invalid file type"
          elsif File.exists? "#{upload_path}/#{name}"
            result[:success] = false
            result[:error]   = "file #{name} already exists"
          else
            File.open("#{upload_path}/#{name}", 'wb'){|f| f.write(contents)}
            result[:success] = true
          end

          result
			  end

			  def expand_file_directory(path, options={})
          #if path is root use root path else append it
          if path == ROOT_NODE
            path = base_path
          end

          render :json => build_tree_for_directory(path, options)
			  end

			  def build_tree_for_directory(directory, options={})
          files_folders = Dir.entries(directory).reject{|file| file =~ REMOVE_FILES_REGEX}.map{|file|
            leaf = !File.directory?(directory + '/' + file)
	    path = (directory + '/' + file).gsub('//', '/')
            downloadPath = path.gsub(File.join(Rails.root.to_s,'public'),'')
            if File.directory?(directory + '/' + file)
              {:text => file, :leaf => leaf, :id => path, :downloadPath => downloadPath}
            elsif !options[:included_file_extensions_regex].nil? && file =~ options[:included_file_extensions_regex]
              {:text => file, :leaf => leaf, :id => path, :downloadPath => downloadPath}
            elsif options[:included_file_extensions_regex].nil?
              {:text => file, :leaf => leaf, :id => path, :downloadPath => downloadPath}
            end
          } if File.directory?(directory)
          
          files_folders.nil? ? [] : files_folders
			  end

			end
		end
	end
end
