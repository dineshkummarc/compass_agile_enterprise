module TechServices
  module FileSupport
    class FileSystemManager < Manager
      REMOVE_FILES_REGEX = /^\./
      
      def initialize
        
      end
      
      def root
        File.join(Rails.root,'public')
      end
      
      def update_file(path, content)
        path = prepend_root_if_needed(path)
        File.open(path, 'w+') {|f| f.write(content) }
      end

      def create_file(path, name, contents)
        path = prepend_root_if_needed(path)
        FileUtils.mkdir_p path unless File.exists? path
        File.open(File.join(path,name), 'w+') {|f| f.write(contents) }
      end

      def create_folder(path, name)
        path = prepend_root_if_needed(path)
        FileUtils.mkdir_p File.join(path,name)
      end

      def save_move(path, new_parent_path)
        path = prepend_root_if_needed(path)
        new_parent_path = prepend_root_if_needed(new_parent_path)
        
        result = nil
        unless File.exists? path
          message = 'File does not exists'
        else
          name = File.basename(path)
          #make sure path is there.
          FileUtils.mkdir_p new_parent_path unless File.directory? new_parent_path
          FileUtils.mv(path, new_parent_path + '/' + name)
          message = "#{name} was moved to #{new_parent_path} successfully"
          result = true
        end

        return result, message
      end

      def rename_file(path, name)
        path = prepend_root_if_needed(path)
        result = nil
        unless File.exists? path
          message = 'File does not exists'
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

      def delete_file(path)
        path = prepend_root_if_needed(path)
        result = nil
        unless File.exists? path
          message = 'File does not exists'
        else
          is_directory = File.directory? path
          name = File.basename(path)
          FileUtils.rm_rf(path)
          message = "#{name} was deleted #{name} successfully"
          result = true
        end

        return result, message, is_directory
      end

      def get_contents(path)
        path = prepend_root_if_needed(path)
        contents = nil
        message = nil
        unless File.exists? path
          message = 'File does not exists'
        else
          contents = IO.read(path)
        end
        return contents, message
      end

      def build_tree(starting_path, options={})
        #starting_path = prepend_root_if_needed(starting_path)
        find_node(starting_path, options)
      end

      def find_node(path, options={})
        parent = if options[:file_asset_holder]
          super
        else
          path_pieces = path.split('/')
          parent = build_tree_for_directory(path, options)
          path_pieces.each do |path_piece|
            next if path_piece.blank?
            parent[:children].each do |child_node|
              if child_node[:text] == path_piece
                parent = child_node
                break
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
        if directory.index(Rails.root).nil?
          tree_data = {:text => directory.split('/').last, :id => directory, :leaf => false, :children => []}
          directory = prepend_root_if_needed(directory)
        else
          keep_full_path = true
          tree_data = {:text => directory.split('/').last, :id => directory, :leaf => false, :children => []}
        end

        Dir.entries(directory).each do |entry|
          #ignore .svn folders and any other folders starting with .
          next if entry =~ REMOVE_FILES_REGEX

          path = File.join(directory, entry)
          path.gsub!(root,'') unless keep_full_path

          if File.directory?(directory + '/' + entry)
            tree_data[:children] << build_tree_for_directory(path, options)
          elsif !options[:included_file_extensions_regex].nil? && entry =~ options[:included_file_extensions_regex]
            tree_data[:children] << {:text => entry, :leaf => true, :downloadPath => path, :id => path}
          elsif options[:included_file_extensions_regex].nil?
            tree_data[:children] << {:text => entry, :leaf => true, :downloadPath => path, :id => path}
          end
        end if File.directory?(directory)

        tree_data[:children].sort_by{|item| [item[:id]]}
        tree_data
      end

      def prepend_root_if_needed(path)
        path.index(Rails.root).nil? ? File.join(root, path) : path
      end
      
    end
  end
end