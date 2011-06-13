class PhoneNumber < ActiveRecord::Base
  include ErpServices::Base::ContactMgtCallbacks
  has_one :contact, :as => :contact_mechanism

  # return first contact purpose
  def contact_purpose
  	contact.contact_purposes.first
  end
  
  #return all contact purposes
  def contact_purposes
  	contact.contact_purposes
  end
  
	def summary_line
		"#{description} : #{phone_number}"
	end

  def eql_to?(phone)
    self.phone_number.reverse.gsub(/[^0-9]/,"")[0..9] == phone.reverse.gsub(/[^0-9]/,"")[0..9]
  end

	def to_label
		"#{description} : #{phone_number}"
	end

  
end
