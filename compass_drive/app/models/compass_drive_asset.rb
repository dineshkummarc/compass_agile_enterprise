#Attributes
#comment           text
#checked_out       boolean
#last_checkout_at  datetime
class CompassDriveAsset < ActiveRecord::Base
  acts_as_versioned :table_name => :compass_drive_versions

  belongs_to :file_asset
  belongs_to :checked_out_by, :class_name => 'User', :foreign_key => 'checked_out_by_id'
  has_one :category_classification, :as => :classification, :dependent => :destroy

  def add_file(file)
    
  end
end

