class PostalAddress < ActiveRecord::Base
  has_contact
  
  belongs_to :geo_country
  belongs_to :geo_zone

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
