class EmailAddress < ActiveRecord::Base
  has_contact

  validates_format_of :email_address, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => "Must be a valid email address"
 
  def summary_line
    "#{description} : #{email_address}"
  end

  def to_label
    "#{description} : #{email_address}"
  end


end
