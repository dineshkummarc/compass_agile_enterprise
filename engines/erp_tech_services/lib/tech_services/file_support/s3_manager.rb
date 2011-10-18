require 'yaml'
require 'aws/s3'

module TechServices
  module FileSupport
    class S3Manager < Manager
      class << self
        def setup_connection
          @@configuration = YAML::load_file(File.join(Rails.root,'config','s3.yml'))[Rails.env]

          AWS::S3::Base.establish_connection!(
            :access_key_id     => @@configuration['access_key_id'],
            :secret_access_key => @@configuration['secret_access_key']
          )

          @@s3_bucket = AWS::S3::Bucket.find(@@configuration['bucket'])
          @@node_tree = build_node_tree
        end
        
        def reload
          AWS::S3::Base.connected? ? (@@node_tree = build_node_tree(true)) : setup_connection
        end

        def build_node_tree(reload=false)
          tree_data = [{:text => @@s3_bucket.name, :leaf => false, :id => '', :children => []}]
          objects = reload ? @@s3_bucket.objects(:reload) : @@s3_bucket.objects()


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
            new_parents = [tree_data[0]]
            levels.each do |level|
              old_parents = new_parents
              new_parents = []
              level.each do |item|
                parent = old_parents.count == 1 ? old_parents.first : self.find_parent(item, old_parents)
                path = File.join(parent[:id], item[:text])
                child_hash = {:last_modified => item[:last_modified], :text => item[:text], :downloadPath => path, :leaf => !File.extname(item[:text]).blank?, :id => path, :children => []}
                new_parents << child_hash
                parent[:children] << child_hash
              end
            end
          end

          tree_data
        end
      end
      
      def buckets
        AWS::S3::Service.buckets
      end
      
      def bucket=(name)
        @@s3_bucket = AWS::S3::Bucket.find(name)
      end
      
      def bucket
        @@s3_bucket
      end
      
      def root
        ''
      end
      
      def update_file(path, content)
        AWS::S3::S3Object.store(path, content, bucket.name)
        TechServices::FileSupport::S3Manager.reload
      end

      def create_file(path, name, contents)
        AWS::S3::S3Object.store(File.join(path,name), contents, @@s3_bucket.name)
        TechServices::FileSupport::S3Manager.reload
      end

      def create_folder(path, name)
        AWS::S3::S3Object.store(File.join(path,name) + "/", '', @@s3_bucket.name)
        TechServices::FileSupport::S3Manager.reload
      end

#      def save_move(path, new_parent_path)
#        result = nil
#        unless File.exists? path
#          message = 'File does not exists'
#        else
#          name = File.basename(path)
#          #make sure path is there.
#          FileUtils.mkdir_p new_parent_path unless File.directory? new_parent_path
#          FileUtils.mv(path, new_parent_path + '/' + name)
#          message = "#{name} was moved to #{new_parent_path} successfully"
#          result = true
#        end
#
#        return result, message
#      end

      def rename_file(path, name)
        result = nil

        old_name = File.basename(path)
        path_pieces = path.split('/')
        path_pieces.delete(path_pieces.last)
        path_pieces.push(name)
        new_path = path_pieces.join('/')
        if AWS::S3::S3Object.rename path, new_path, @@s3_bucket.name, :copy_acl => true
          message = "#{old_name} was renamed to #{name} successfully"
          result = true
        else
          message = "#Error renaming {old_name}"
        end
        TechServices::FileSupport::S3Manager.reload
        
        return result, message
      end

      def delete_file(path)
        result = nil
        message = nil

        node = find_node(path)
        if node[:children].empty?
          is_directory = File.extname(path).blank?
          AWS::S3::S3Object.delete path, @@s3_bucket.name, :force => true
          message = "File was deleted successfully"
          result = true
        else
          message = "Folder is not empty"
        endend unless node.nil?
        TechServices::FileSupport::S3Manager.reload

        return result, message, is_directory
      end

      def exists?(path)
        !AWS::S3::S3Object.find(path, @@s3_bucket.name).nil?
      end

      def get_contents(path)
        contents = nil
        message = nil

        path = path[1..path.length]
        begin
          object = AWS::S3::S3Object.find path, @@s3_bucket.name
        rescue AWS::S3::NoSuchKey => error
          message = 'File does not exists'
        end
        
        contents = object.value if message.nil?

        return contents, message
      end

      def build_tree(starting_path, options={})
        node_tree = find_node(starting_path, options)
        node_tree.nil? ? [] : node_tree
      end

      private

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
            parent = nil if parent[:id] != path
          end
          
          parent
        end

        parent
      end
      
    end#S3Manager
  end#FileSupport
end#TechServices