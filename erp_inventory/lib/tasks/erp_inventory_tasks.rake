namespace :erp_inventory do
  desc 'Clear all inventory'
  task :clear => :environment do
    InventoryEntry.destroy_all
  end

  desc 'Initial load for inventory'
  task :initial_load => :environment do
    product_types = ProductType.all
    product_types.each do |product_type|
      count = ProductInstance.count(:conditions => ['product_type_id = ?', product_type.id])
      puts "Creating inventory for #{product_type.description}"
      InventoryEntry.create(:description => "Inventory for #{product_type.description}", :product_type_id => product_type.id, :number_available => count)
    end
  end
end
