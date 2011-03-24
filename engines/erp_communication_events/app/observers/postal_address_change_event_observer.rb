class PostalAddressChangeEventObserver < ActiveRecord::Observer
  observe :postal_address

  def after_save(address)
    create_change_event(address)
  end

  private

  def create_change_event(address)
  end
  
end
