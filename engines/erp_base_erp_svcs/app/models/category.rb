class Category < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :category_record, :polymorphic => true
  has_many :category_classifications, :dependent => :destroy
  
  def self.iid( internal_identifier_string )
    find( :first, :conditions => [ 'internal_identifier = ?', internal_identifier_string.to_s ])
  end
  
end
