module ErpTechSvcs
  module FileSupport
    class FileSystemManager < Manager
      REMOVE_FILES_REGEX = /^\./

      def root
        Rails.root
      end

      def update_file(path, content)
        File.open(path, 'w+:ASCII-8BIT') {|f| f.write(content) }
      end

      def create_file(path, name, contents)
        FileUtils.mkdir_p path unless File.exists? path
        File.open(File.join(path,name), 'w+:ASCII-8BIT') {|f| f.write(contents) }
      end

      def create_folder(path, name)
        FileUtils.mkdir_p File.join(path,name) unless File.directory? File.join(path,name)
      end

      def save_move(path, new_parent_path)
        old_path = File.join(root,path)
        new_path = File.join(root,new_parent_path)
        result = false
        unless File.exists? old_path
          message = FILE_DOES_NOT_EXIST
        else
          name = File.basename(path)
          #make sure path is there.
          FileUtils.mkdir_p new_path unless File.directory? new_path
          FileUtils.mv(old_path, File.join(new_path,name))
          message = "#{name} was moved to #{new_parent_path} successfully"
          result = true
        end

        return result, message
      end

      def exists?(path)
        File.exists? path
      end

      def rename_file(path, name)
        result = false
        unless File.exists? path
          message = FILE_DOES_NOT_EXIST
        else
          old_name = File.basename(path)
          path_pieces = path.split('/')
          path_pieces.delete(path_pieces.last)
          path_pieces.push(name)
          new_path = path_pieces.join('/')
          File.rename(path, new_path)
          message = "#{old_name} was renamed to #{name} successfully"
          result = true
        end

        return result, message
      end

      def delete_file(path, options={})
        result = false
        name = File.basename(path)
        is_directory = false
        if !File.exists? path and !File.directory? path
          message = FILE_FOLDER_DOES_NOT_EXIST
        else
          if File.directory? path
            is_directory = true
            entries = Dir.entries(path)
            entries.delete_if{|entry| entry =~ REMOVE_FILES_REGEX}
            if entries.count > 0 && !options[:force]
              message = FOLDER_IS_NOT_EMPTY
              result = false;
            else
              FileUtils.rm_rf(path)
              message = "Folder #{name} was deleted #{name} successfully"
              result = true
            end
          else
            FileUtils.rm_rf(path)
            message = "File #{name} was deleted #{name} successfully"
            result = true
          end
        end

        return result, message, is_directory
      end

      def get_contents(path)
        contents = nil
        message = nil
        unless File.exists? path
          message = FILE_DOES_NOT_EXIST
        else
          contents = IO.read(path).force_encoding('ASCII-8BIT')
        end
        return contents, message
      end

      def build_tree(starting_path, options={})
        find_node(starting_path, options)
      end

      def find_node(path, options={})
        parent = if options[:file_asset_holder]
          super
        else
          path_pieces = path.split('/')
          parent = build_tree_for_directory(path, options)
          unless parent[:id] == path
            path_pieces.each do |path_piece|
              next if path_piece.blank?
              parent[:children].each do |child_node|
                if child_node[:text] == path_piece
                  parent = child_node
                  break
                end
              end
            end
          end

          parent = nil if parent[:id] != path
          parent
        end

        parent
      end

      private

      def build_tree_for_directory(directory, options)
        keep_full_path = nil
        if directory.index(Rails.root.to_s).nil?
          tree_data = {:text => directory.split('/').last, :id => directory, :leaf => false, :children => []}
        else
          keep_full_path = true
          tree_data = {:text => directory.split('/').last, :id => directory, :leaf => false, :children => []}
        end

        Dir.entries(directory).each do |entry|
          #ignore .svn folders and any other folders starting with .
          next if entry =~ REMOVE_FILES_REGEX

          path = File.join(directory, entry)
          path.gsub!(root,'') unless keep_full_path

          if File.directory?(File.join(directory,entry))
            tree_data[:children] << if options[:preload]
              build_tree_for_directory(path, options) if options[:preload]
            else
              {:text => entry, :id => path, :iconCls => 'icon-content'}
            end
          elsif !options[:included_file_extensions_regex].nil? && entry =~ options[:included_file_extensions_regex]
            tree_data[:children] << {:text => entry, :leaf => true, :iconCls => 'icon-document', :downloadPath => directory, :id => path}
          elsif options[:included_file_extensions_regex].nil?
            tree_data[:children] << {:text => entry, :leaf => true, :iconCls => 'icon-document', :downloadPath => directory, :id => path}
          end
        end if File.directory?(directory)

        tree_data[:children].sort_by!{|item| [item[:text]]}
        tree_data
      end

    end#FileSystemManager
  end#FileSupport
end#ErpTechSvcs