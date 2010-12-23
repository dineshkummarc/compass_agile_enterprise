class SeedTreeMenuDefsProductMgt < ActiveRecord::Migration
  def self.up
    ############################################
    # Product Management Tree Menu             #
    ############################################
    
    # Add the root menu node
    pm_root = TreeMenuNodeDef.create( :node_type => 'category',
                                      :menu_short_name => 'product_mgt_tree',
                                      :menu_description => 'Product Mgt'
                                    )
                                    
    # Now add each of the child menu nodes
    product_types = TreeMenuNodeDef.create( :node_type => 'url',
                                            :text => 'Product Types',
                                            :menu_short_name => 'product_mgt_tree',
                                            :menu_description => 'Product Mgt Scaffolds',
                                            :target_url => '/product_mgt_product_types'
                                          )
    
    product_instances = TreeMenuNodeDef.create( :node_type => 'url',
                                                :text => 'Product Instances',
                                                :menu_short_name => 'product_mgt_tree',
                                                :menu_description => 'Product Mgt Scaffolds',
                                                :target_url => '/product_mgt_product_instances'
                                              )

    inventory_entries = TreeMenuNodeDef.create( :node_type => 'url',
                                                :text => 'Inventory Entries',
                                                :menu_short_name => 'product_mgt_tree',
                                                :menu_description => 'Product Mgt Scaffolds',
                                                :target_url => '/product_mgt_inventory_entries'
                                              )
    # declare image assets url to use same model/controller as content_mgt_tree 
    url_image_assets = TreeMenuNodeDef.create( :node_type => 'url',
                                               :text => 'Image Assets',
                                               :menu_short_name => 'product_mgt_tree',
                                               :menu_description => 'Product Mgt Scaffolds',
                                               :target_url => '/content_mgt_image_assets'
                                             )
    
    # And link them all up in their proper place                                      
    product_types.move_to_child_of pm_root
    product_instances.move_to_child_of pm_root
    inventory_entries.move_to_child_of pm_root
    url_image_assets.move_to_child_of pm_root
  end

  def self.down
    pm_tree_roots = TreeMenuNodeDef.find(:all, :conditions => 
      ["node_type = 'category' AND menu_short_name = 'product_mgt_tree' and menu_description = 'Product Mgt'"])
    pm_tree_roots.each {|t| t.destroy}
  end
end