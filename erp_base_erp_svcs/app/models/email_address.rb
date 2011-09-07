class EmailAddress < ActiveRecord::Base
  has_contact
 
  def summary_line
    "#{description} : #{email_address}"
  end

  def to_label
    "#{description} : #{email_address}"
  end


end
