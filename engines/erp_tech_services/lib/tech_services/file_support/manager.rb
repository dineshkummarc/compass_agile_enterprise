module TechServices
  module FileSupport
    class Manager

      protected

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
              if item.split('/').count >= i && current_items.index(text).nil?
                current_items << text
                {:text => text, :path => item.split('/')[0..(i-1)].join('/')}
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
          node = find_node(child_asset_node[:id])
          folders = node[:children].select{|item| !item[:leaf]}
          folders.each do |folder|
            child_asset_node[:children] << folder unless child_asset_node[:children].collect{|child_node| child_node[:text] }.include?(folder[:text])
          end
          insert_folders(child_asset_node[:children])
        end unless file_asset_nodes.nil?
      end

      class << self
        def find_parent(item, parents)
          parents.find do |parent|
            path = item[:path].gsub(item[:text],'').split('/').join('/')
            parent[:id] == path
          end
        end
      end

    end
  end
end
