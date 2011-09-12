class CreateOrderPartyRoles
  
  def self.up
    order_roles = BizTxnPartyRoleType.create(
      :description => 'Order Roles',
      :internal_identifier => 'order_roles'
    )

    buyor_role = BizTxnPartyRoleType.create(
      :description => 'Buyer',
      :internal_identifier => 'buyer'
    )

    buyor_role.move_to_child_of(order_roles)
    buyor_role.save
  end
  
  def self.down
    BizTxnPartyRoleType.find_by_internal_identifier('buyor').destroy
    BizTxnPartyRoleType.find_by_internal_identifier('order_roles').destroy
  end

end
