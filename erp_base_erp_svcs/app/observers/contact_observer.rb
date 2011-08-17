class ContactObserver < ActiveRecord::Observer
  observe :email_address, :postal_address, :phone_number
  
  def after_initialize()
    if self.new_record? and self.contact.nil?
      self.contact = Contact.new
      self.contact.description = self.description
    end
  end
end