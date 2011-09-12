class PhoneNumberChangeEventObserver < ActiveRecord::Observer
  observe :phone_number
  
  def after_save(phone)
    create_change_event(phone)
  end

  private

  def create_change_event(phone)
  end
  
end
