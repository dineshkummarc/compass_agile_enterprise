class EmailAddressChangeEventObserver < ActiveRecord::Observer
  observe :email_address

  def after_save(email)
    create_change_event(email)
  end

  private

  def create_change_event(email)    
  end
  
end