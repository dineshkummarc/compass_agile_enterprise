class EmailAddress < ActiveRecord::Base
  #include ErpServices::Base::ContactMgtCallbacks
  has_one :contact, :as => :contact_mechanism
 
  # return first contact purpose
  def contact_purpose
    contact.contact_purposes.first
  end
  
  # return all contact purposes
  def contact_purposes
    contact.contact_purposes
  end
  
  def summary_line
    "#{description} : #{email_address}"
  end

  def to_label
    "#{description} : #{email_address}"
  end


end
