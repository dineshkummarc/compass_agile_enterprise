class AddSecuredModelsToMenuItems
  
  def self.up
    WebsiteNavItem.all.each do |nav_item|
      if nav_item.secured_model.nil?
        secured_model = SecuredModel.new
        nav_item.secured_model = secured_model
        secured_model.secured_record = nav_item
        nav_item.save
      end
    end
  end
  
  def self.down
    #remove data here
  end

end
