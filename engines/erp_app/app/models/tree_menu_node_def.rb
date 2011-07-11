class TreeMenuNodeDef < ActiveRecord::Base

  # For Rails 2.1: override default of include_root_in_json
  # (the Ext.tree.TreeLoader cannot use the additional nesting)
  TreeMenuNodeDef.include_root_in_json = false if TreeMenuNodeDef.respond_to?(:include_root_in_json)

  acts_as_nested_set

#***************************************************************************
# needed for regular nested sets, but we're using the 'better_nested_set'
# plugin, which provides this functionality with different method names
#***************************************************************************
#  def self.root_nodes
#    self.roots
#  end
#  def children_count
#    children.size
#  end

  def refers_to_ar_class?
    return (self.resource_class != nil) 
  end

  def find_parent_text
    parent_text = ''

    unless self.parent_id.nil?
      parent_text = self.parent.text
    end

    parent_text

  end

  def self.find_menu_roots( menu_short_name )
    find( :all, :conditions => {:parent_id => nil, :menu_short_name  => menu_short_name})
  end

  def self.find_children(parent_id = nil)
    parent_id.to_i == 0 ? self.roots : find(parent_id).children
  end

  def leaf
    unknown? ||  children.size == 0
  end

  def to_json_with_leaf(options = {})
    self.to_json_without_leaf(options.merge(:methods => :leaf))
  end
  alias_method_chain :to_json, :leaf     
  
end
