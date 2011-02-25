require 'fileutils'

class ErpApp::Desktop::FileManager::BaseController < ErpApp::Desktop::BaseController
  REMOVE_FILES_REGEX = /^\./
  ROOT_NODE = 'root_node'

  def initialize
    @base_path = Rails.root.to_s
  end

  def update_file
    path     = params[:node]
    content = params[:content]

    File.open(path, 'w+') {|f| f.write(content) }

    render :inline => {:success => true}.to_json
  end

  def create_file
    path = params[:path]
    name = params[:name]

    File.open(File.join(path,name), 'w+') {|f| f.write('') }

    render :inline => {:success => true}.to_json
  end

  def create_folder
    path = params[:path]
    name = params[:name]

    FileUtils.mkdir_p File.join(path,name)

    render :inline => {:success => true}.to_json
  end

  def download_file
    path = params[:path]

    send_file path, :type=>"text/plain"
  end

  def save_move
    path            = params[:node]
    new_parent_path = params[:parent_node]

    unless File.exists? path
      json_str = "{success:false, msg:'File does not exists'}"
    else
      name = File.basename(path)
      FileUtils.mv(path, new_parent_path + '/' + name)
      json_str = "{success:true, msg:'#{name} was moved to #{new_parent_path} successfully'}"
    end

    render :inline => json_str
  end

  def rename_file
    path = params[:node]
    name = params[:file_name]

    unless File.exists? path
      json_str = "{success:false, msg:'File does not exists'}"
    else
      old_name = File.basename(path)
      path_pieces = path.split('/')
      path_pieces.delete(path_pieces.last)
      path_pieces.push(name)
      new_path = path_pieces.join('/')
      File.rename(path, new_path)
      json_str = "{success:true, msg:'#{old_name} was renamed to #{name} successfully'}"
    end

    render :inline => json_str
  end

  def delete_file
    path = params[:node]
    
    unless File.exists? path
      json_str = "{success:false, error:'File does not exists'}"
    else
      name = File.basename(path)
      File.delete(path)
      json_str = "{success:true, error:'#{name} was deleted successfully'}"
    end

    render :inline => json_str
  end

  def upload_file
    if request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank?
      upload_path = params[:directory]
    else
      upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
    end

    upload_path = @base_path if upload_path == ROOT_NODE

    result = upload_file_to_path(upload_path)

    render :inline => result
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

    unless File.directory? upload_path
      FileUtils.mkdir_p(upload_path)
    end

    unless request.env['HTTP_X_FILE_NAME'].blank?
      contents = request.raw_post
      name     = request.env['HTTP_X_FILE_NAME']
    else
      file_contents = params[:file_data]
      name = file_contents.original_path
      if file_contents.respond_to?(:read)
        contents = file_contents.read
      elsif file_contents.respond_to?(:path)
        contents = File.read(file_contents.path)
      end
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

    result.to_json
  end

  def expand_file_directory(path, options={})
    #if path is root use root path else append it
    if path == ROOT_NODE
      path = @base_path
    end

    render :inline => build_tree_for_directory(path, options)
  end

  def build_tree_for_directory(directory, options)
    tree_data = []
    
    Dir.entries(directory).each do |entry|
      #ignore .svn folders and any other folders starting with .
      next if entry =~ REMOVE_FILES_REGEX

      #check if we want folders only
      if options[:folders_only]
        if File.directory?(directory + '/' + entry)
          leaf = false
        end
      else
        #check if this is a directory
        if File.directory?(directory + '/' + entry)
          leaf = false
        else
          leaf = true
        end
      end
      if File.directory?(directory + '/' + entry)
        tree_data << {:text => entry, :leaf => leaf, :id => (directory + '/' + entry).gsub('//', '/')}
      elsif !options[:included_file_extensions_regex].nil? && entry =~ options[:included_file_extensions_regex]
        tree_data << {:text => entry, :leaf => leaf, :id => (directory + '/' + entry).gsub('//', '/')}
      elsif options[:included_file_extensions_regex].nil?
        tree_data << {:text => entry, :leaf => leaf, :id => (directory + '/' + entry).gsub('//', '/')}
      end 
    end if File.directory?(directory)
    
    tree_data.to_json
  end
end