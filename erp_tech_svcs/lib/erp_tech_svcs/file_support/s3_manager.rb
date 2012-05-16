require 'yaml'
require 'aws/s3'

module ErpTechSvcs
  module FileSupport
    class S3Manager < Manager
      class << self
        cattr_accessor :node_tree, :s3_connection

        def setup_connection
          @@configuration = YAML::load_file(File.join(Rails.root,'config','s3.yml'))[Rails.env]
          
          # S3 debug logging
          # AWS.config(
          #   :logger => Rails.logger,
          #   :log_level => :info
          # )

          @@s3_connection = AWS::S3.new(
            :access_key_id     => @@configuration['access_key_id'],
            :secret_access_key => @@configuration['secret_access_key']
          )

          @@s3_bucket = @@s3_connection.buckets[@@configuration['bucket'].to_sym]
          cache_node_tree(build_node_tree(true))
        end

        def reload
          !@@s3_connection.nil? ? (cache_node_tree(build_node_tree(true))) : setup_connection
        end

        def cache_key
          'node_tree'
        end

        def cache_node_tree(node_tree)
          Rails.cache.write(cache_key, node_tree, :expires_in => ErpTechSvcs::Config.s3_cache_expires_in_minutes.minutes)
          return node_tree
        end

        def add_children(parent_hash, tree)
          tree.children.each do |child|
            child_hash = {
              :last_modified => '',
              #:last_modified => (child.leaf? ? @@s3_bucket.objects[child.key].last_modified : ''), 
              :text => (child.leaf? ? File.basename(child.key) : File.basename(child.prefix)), 
              :downloadPath => (child.leaf? ? '/'+File.dirname(child.key) : "/#{child.parent.prefix}".sub(%r{/$},'')), 
              :leaf => child.leaf?, 
              :id => (child.leaf? ? '/'+child.key : "/#{child.prefix}".sub(%r{/$},'')), 
              :children => []
            }
            child_hash = add_children(child_hash, child) unless child.leaf?
            parent_hash[:children] << child_hash 
          end

          parent_hash
        end

        def build_node_tree(reload=false)
          node_tree = Rails.cache.read(cache_key)
          if !reload and !node_tree.nil?
            #Rails.logger.info "@@@@@@@@@@@@@@ USING CACHED node_tree: #{node_tree.inspect}"
            return node_tree
          end

          tree_data = {:text => @@s3_bucket.name, :leaf => false, :id => '', :children => []}
          tree_data = [add_children(tree_data, @@s3_bucket.as_tree)]
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

      def cache_key
        ErpTechSvcs::FileSupport::S3Manager.cache_key
      end

      def clear_cache(path)
        path = path.sub(%r{^/},'')
        #Rails.logger.info "deleting cache with key: #{path}"
        Rails.cache.delete(path) # delete template from cache
        Rails.cache.delete(cache_key) # delete node tree from cache
        reload#preload the tree and cache
      end

      def update_file(path, content)
        path = path.sub(%r{^/},'')
        bucket.objects[path].write(content)
        clear_cache(path)
      end

      def create_file(path, name, content)
        path = path.sub(%r{^/},'')
        bucket.objects[File.join(path, name)].write(content)
        clear_cache(path)
      end

      def create_folder(path, name)
        path = path.sub(%r{^/},'')
        folder = File.join(path, name) + "/"
        bucket.objects[folder].write('')
        clear_cache(path)
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
            clear_cache(path)
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
            clear_cache(path)
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
        path = path.sub(%r{^/},'')
        result = false
        message = nil

        begin
          is_directory = !bucket.objects[path].exists?
          if options[:force] or bucket.as_tree(:prefix => path).children.count == 0
            bucket.objects.with_prefix(path).delete_all
            message = "File was deleted successfully"
            result = true
            clear_cache(path)
          else
            message = FOLDER_IS_NOT_EMPTY
          end
        rescue Exception => e
          result = false
          message = e
        end    

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
        #ErpTechSvcs::FileSupport::S3Manager.reload
        node_tree = find_node(starting_path, options)
        node_tree.nil? ? [] : node_tree
      end

      def find_node(path, options={})
        parent = if options[:file_asset_holder]
          super
        else
          parent = ErpTechSvcs::FileSupport::S3Manager.build_node_tree(false).first
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