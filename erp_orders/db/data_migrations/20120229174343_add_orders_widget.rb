class AddOrdersWidget
  
  def self.up
    #insert data here
    if Widget.find_by_internal_identifier('order_management').nil?
      app = Application.find_by_internal_identifier('crm')

      orders = Widget.create(
          :description => 'Order Managament',
          :internal_identifier => 'order_management',
          :icon => 'icon-grid',
          :xtype => 'partyorderstab'
        )

      app.widgets << orders
      app.save

      orders.roles << Role.find_by_internal_identifier('admin')
      orders.save      
    end
  end
  
  def self.down
    #remove data here
    Widget.find_by_internal_identifier('order_management').destroy
  end

end
