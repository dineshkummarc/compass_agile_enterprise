class PostalAddress < ActiveRecord::Base
  has_contact
  
  belongs_to :geo_country
  belongs_to :geo_zone

  # return first contact purpose
  def contact_purpose
  	contact.contact_purposes.first
  end
  
  #return all contact purposes
  def contact_purposes
  	contact.contact_purposes
  end
  
	def summary_line
		"#{description} : #{address_line_1}, #{city}"
	end
	
	def to_label
		"#{description} : #{address_line_1}, #{city}"    
	end

  def zip_eql_to?(zip)
    self.zip.downcase.gsub(/[^a-zA-Z0-9]/, "")[0..4] == zip.to_s.downcase.gsub(/[^a-zA-Z0-9]/,"")[0..4]
  end

end
