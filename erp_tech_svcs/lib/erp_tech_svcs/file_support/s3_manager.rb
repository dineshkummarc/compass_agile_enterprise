require 'yaml'
require 'aws/s3'

module ErpTechSvcs
  module FileSupport
    class S3Manager < Manager
      class << self
        cattr_accessor :node_tree

        def setup_connection
          @@configuration = YAML::load_file(File.join(Rails.root,'config','s3.yml'))[Rails.env]

          @@s3_connection = AWS::S3.new(
            :access_key_id     => @@configuration['access_key_id'],
            :secret_access_key => @@configuration['secret_access_key']
          )

          @@s3_bucket = @@s3_connection.buckets[@@configuration['bucket'].to_sym]
          @@node_tree = build_node_tree
        end

        def reload
          !@@s3_connection.nil? ? (@@node_tree = build_node_tree(true)) : setup_connection
        end

        def build_node_tree(reload=false)
          tree_data = [{:text => @@s3_bucket.name, :leaf => false, :id => '', :children => []}]
          #objects = reload ? @@s3_bucket.objects(:reload) : @@s3_bucket.objects()
          objects = @@s3_bucket.objects


          nesting_depth = objects.collect{|object| object.key.split('/').count}.max
          unless nesting_depth.nil?
            levels = []
            (1..nesting_depth).each do |i|
              current_items = []
              objects_this_depth = objects.collect{|object|
                text = object.key.split('/')[i - 1]
                path ='/' + (object.key.split('/')[0..(i-1)].join('/'))
                if object.key.split('/').count >= i && current_items.select{|item| item[:text] == text and item[:path] == path}.empty?
                  item_hash = {:text => text, :path => path, :last_modified => object.last_modified}
                  current_items << item_hash
                  item_hash
                end
              }
              objects_this_depth.delete_if{|item| (item.nil? or item[:text].nil?)}
              levels << objects_this_depth
            end

            old_parents = []
            new_parents = [tree_data.first]
            levels.each do |level|
              old_parents = new_parents
              new_parents = []
              level.each do |item|
                parent = old_parents.count == 1 ? old_parents.first : self.find_parent(item, old_parents)
                path = File.join(parent[:id], item[:text])
                child_hash = {:last_modified => item[:last_modified], :text => item[:text], :downloadPath => parent[:id], :leaf => !File.extname(item[:text]).blank?, :id => path, :children => []}
                new_parents << child_hash
                parent[:children] << child_hash
              end
            end
          end

          tree_data
        end
      end

      def buckets
        @@s3_connection.buckets
      end

      def bucket=(name)
        @@s3_bucket = @@s3_connection.buckets[name.to_sym]
      end

      def bucket
        @@s3_bucket
      end

      def root
        ''
      end

      def update_file(path, content)
        path = path.sub(%r{^/},'')
        bucket.objects[path].write(content)
      end

      def create_file(path, name, content)
        path = path.sub(%r{^/},'')
        bucket.objects[File.join(path, name)].write(content)
        ErpTechSvcs::FileSupport::S3Manager.reload
      end

      def create_folder(path, name)
        path = path.sub(%r{^/},'')
        folder = File.join(path, name) + "/"
        bucket.objects[folder].write('')
        ErpTechSvcs::FileSupport::S3Manager.reload
      end

      def save_move(path, new_parent_path)
        result = false
        unless self.exists? path
          message = FILE_DOES_NOT_EXIST
        else
          file = FileAsset.where(:name => ::File.basename(path)).where(:directory => ::File.dirname(path)).first
          acl = (file.has_capabilities? ? :private : :public_read) unless file.nil?
          options = (file.nil? ? {} : {:acl => acl})
          name = File.basename(path)
          path = path.sub(%r{^/},'')
          new_path = File.join(new_parent_path,name).sub(%r{^/},'')
          old_object = bucket.objects[path]
          if new_object = old_object.move_to(new_path, options)
            message = "#{name} was moved to #{new_path} successfully"
            result = true
            ErpTechSvcs::FileSupport::S3Manager.reload
          else
            message = "Error moving file #{path}"
          end
        end

        return result, message
      end

      def rename_file(path, name)
        result = false
        old_name = File.basename(path)
        path_pieces = path.split('/')
        path_pieces.delete(path_pieces.last)
        path_pieces.push(name)
        new_path = path_pieces.join('/')
        begin
          file = FileAsset.where(:name => ::File.basename(path)).where(:directory => ::File.dirname(path)).first
          acl = (file.has_capabilities? ? :private : :public_read) unless file.nil?
          options = (file.nil? ? {} : {:acl => acl})
          path = path.sub(%r{^/},'')
          new_path = new_path.sub(%r{^/},'')
#          Rails.logger.info "renaming from #{path} to #{new_path}"
          old_object = bucket.objects[path]
          if new_object = old_object.move_to(new_path, options)
            message = "#{old_name} was renamed to #{name} successfully"
            result = true
            ErpTechSvcs::FileSupport::S3Manager.reload
          else
            message = "Error renaming #{old_name}"
          end
        rescue AWS::S3::Errors::NoSuchKey=>ex
          message = FILE_FOLDER_DOES_NOT_EXIST
        end

        return result, message
      end

      def set_permissions(path, canned_acl=:public_read)
        path = path.sub(%r{^/},'')
        bucket.objects[path].acl = canned_acl
      end

      def delete_file(path, options={})
        result = false
        message = nil

        node = find_node(path)
        if node[:children].empty?
          is_directory = !node[:leaf]
          path << '/' unless node[:leaf]
          path = path.sub(%r{^/},'')
          result = bucket.objects[path].delete
          message = "File was deleted successfully"
          result = true
          ErpTechSvcs::FileSupport::S3Manager.reload
        elsif options[:force]
          node[:children].each do |child|
            delete_file(child[:id], options)
          end
        else
          message = FOLDER_IS_NOT_EMPTY
        end unless node.nil?

        return result, message, is_directory
      end

      def exists?(path)
        begin
          path = path.sub(%r{^/},'')
          !bucket.objects[path].nil?
        rescue AWS::S3::Errors::NoSuchKey
          return false
        end
      end

      def get_contents(path)
        contents = nil
        message = nil

        path = path.sub(%r{^/},'')
        begin
          object = bucket.objects[path]
        rescue AWS::S3::Errors::NoSuchKey => error
          message = FILE_DOES_NOT_EXIST
        end

        contents = object.read if message.nil?

        return contents, message
      end

      def build_tree(starting_path, options={})
        starting_path = "/" + starting_path unless starting_path.first == "/"
        ErpTechSvcs::FileSupport::S3Manager.reload
        node_tree = find_node(starting_path, options)
        node_tree.nil? ? [] : node_tree
      end

      def find_node(path, options={})
        parent = if options[:file_asset_holder]
          super
        else
          parent = @@node_tree.first
          unless path.nil?
            path_pieces = path.split('/')
            path_pieces.each do |path_piece|
              next if path_piece.blank?
              parent[:children].each do |child_node|
                if child_node[:text] == path_piece
                  parent = child_node
                  break
                end
              end
            end
            parent = nil unless parent[:id] == path
          end

          parent
        end

        parent
      end

    end#S3Manager
  end#FileSupport
end#ErpTechSvcs