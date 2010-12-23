class SeedTreeMenuDefsEca < ActiveRecord::Migration
  def self.up
    entity_content_assignments = TreeMenuNodeDef.create( :node_type => 'url',
                                                         :text => 'Entity Content Assignments',
                                                         :menu_short_name => 'product_mgt_tree',
                                                         :menu_description => 'Product Mgt Scaffolds',
                                                         :target_url => '/product_mgt_entity_assignments'
                                                       )
    pm_root = TreeMenuNodeDef.find_by_node_type_and_menu_short_name('category', 'product_mgt_tree')      

    entity_content_assignments.move_to_child_of pm_root
    
  end

  def self.down
  end
end
