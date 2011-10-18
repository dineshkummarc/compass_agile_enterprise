module TechServices
  module FileSupport
    class Manager

      class << self
        def find_parent(item, parents)
          parents.find do |parent|
            path = item[:path].gsub(item[:text],'').split('/').join('/')
            parent[:id] == path
          end
        end
      end

      def sync(path, model)
        result = nil
        message = nil

        node = find_node(path)
        if node.nil?
          message = "Nothing to sync"
        else
          sync_node(node, model)
          message = "Sync successful"
          result = true
        end

        return result, message
      end

      def find_node(path, options={})
        node_tree = build_file_assets_tree_for_model(options[:file_asset_holder])

        path_pieces = path.split('/')
        parent = node_tree.first
        path_pieces.each do |path_piece|
          next if path_piece.blank?
          parent[:children].each do |child_node|
            if child_node[:text] == path_piece
              parent = child_node
              break
            end
          end
        end

        path.sub!(self.root,'') if parent[:id].scan(self.root).empty?

        parent = [] if parent[:id] != path
        parent
      end

      def build_file_assets_tree_for_model(model)
        node_tree = [{:text => root, :leaf => false, :id => root, :children => []}]

        paths = model.files.collect{|file| File.join(file.directory,file.name)}

        nesting_depth = paths.collect{|item| item.split('/').count}.max
        unless nesting_depth.nil?
          levels = []
          (1..nesting_depth).each do |i|
            current_items = []
            objects_this_depth = paths.collect{|item|
              text = item.split('/')[i - 1]
              path = item.split('/')[0..(i-1)].join('/')
              if item.split('/').count >= i && current_items.select{|item| item[:text] == text and item[:path] == path}.empty?
                item_hash = {:text => text, :path => path}
                current_items << item_hash
                item_hash
              end
            }
            objects_this_depth.delete_if{|item| (item.nil? or item[:text].blank?)}
            levels << objects_this_depth unless objects_this_depth.empty?
          end

          old_parents = []
          new_parents = [node_tree[0]]
          levels.each do |level|
            old_parents = new_parents
            new_parents = []
            level.each do |item|
              parent = old_parents.count == 1 ? old_parents.first : self.class.find_parent(item, old_parents)
              path = File.join(parent[:id], item[:text]).gsub(root, '')
              child_hash = {:text => item[:text], :downloadPath => path, :leaf => !File.extname(item[:text]).blank?, :id => path, :children => []}
              new_parents << child_hash
              parent[:children] << child_hash
            end
          end

          insert_folders(node_tree.first[:children])
        end

        node_tree
      end

      def insert_folders(file_asset_nodes)
        file_asset_nodes.each do |child_asset_node|
          node = find_node(File.join(self.root,child_asset_node[:id]))
          folders = node[:children].select{|item| !item[:leaf]}
          folders.each do |folder|
            child_asset_node[:children] << folder unless child_asset_node[:children].collect{|child_node| child_node[:text] }.include?(folder[:text])
          end
          insert_folders(child_asset_node[:children])
        end unless file_asset_nodes.nil?
      end

      private

      def sync_node(node, model)
        leaves = get_all_leaves(node)
        leaves.each do |leaf|
          create_file_asset_for_node(leaf, model)
        end

        model.files.find(:all, :conditions => "directory like '#{node[:id].sub(self.root, '')}%'").each do |file_asset|
          unless self.exists? File.join(self.root, file_asset.directory, file_asset.name)
            puts "File #{File.join(self.root, file_asset.directory, file_asset.name)} does not exists removing"
            file_asset.destroy
          end
        end
      end

      def get_all_leaves(node)
        node[:children].map{|child_node| child_node[:leaf] ? child_node : get_all_leaves(child_node) }.flatten
      end

      def create_file_asset_for_node(node, model)
        name = File.basename(node[:id])
        directory = File.dirname(node[:id])
        file_asset = model.files.find(:first, :conditions => ['directory = ? and name = ?', directory, name])

        if file_asset.nil?
          contents = get_contents(node[:id]).to_s
          begin
            model.add_file(contents, node[:id])
          rescue Exception=>ex
            #the file might already exist if it is in the file system.
          end
        end
      end
      
    end#Manager
  end#FileSupport
end#TechServices
