class TreeMenuNodeDef < ActiveRecord::Base
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

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
    where("parent_id = nil and menu_short_name  = menu_short_name")
  end

  def self.find_children(parent_id = nil)
    parent_id.to_i == 0 ? self.roots : find(parent_id).children
  end

  def leaf
    unknown? || children.size == 0
  end

  def to_json_with_leaf(options = {})
    self.to_json_without_leaf(options.merge(:methods => :leaf))
  end
  alias_method_chain :to_json, :leaf     
  
end
