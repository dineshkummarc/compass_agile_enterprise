class CreateOrderPartyRoles
  
  def self.up
    order_roles = BizTxnPartyRoleType.create(
      :description => 'Order Roles',
      :internal_identifier => 'order_roles'
    )

    buyor_role = BizTxnPartyRoleType.create(
      :description => 'Payor',
      :internal_identifier => 'payor'
    )

    buyor_role.move_to_child_of(order_roles)
    buyor_role.save
  end
  
  def self.down
    BizTxnPartyRoleType.find_by_internal_identifier('payor').destroy
    BizTxnPartyRoleType.find_by_internal_identifier('order_roles').destroy
  end

end
