class TreeMenuNodeView
	
	# For Rails 2.1: override default of include_root_in_json
	# (the Ext.tree.TreeLoader cannot use the additional nesting)
	TreeMenuNodeView.include_root_in_json = false if TreeMenuNodeView.respond_to?(:include_root_in_json)
	
	attr_accessor :id, :node_type, :record_id, :text, :klass_name, :parent_node, :child_nodes, :target_url, :icon, :iconCls
	
	def initialize
		@child_nodes = []
  end

  def set_parent_node (node_view )
    node_view.child_nodes << self.id
    @parent_node = node_view.id
  end

		
end