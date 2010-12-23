class EntityContentAssignment < ActiveRecord::Base

  belongs_to :da_assignment, :polymorphic => true
  belongs_to :content_mgt_asset

  delegate :public_filename, :image, :to => :content_mgt_asset, :allow_nil => true
  
  named_scope :images, :include => :content_mgt_asset, :conditions => {'content_mgt_assets.digital_asset_type' => 'ImageAsset' }
  
  def default_list_image_flag=(newval)
    if da_assignment != nil
      self.da_assignment.list_view_image_url = content_mgt_asset.url
      self.da_assignment.save
      super
    else
      raise "must set da assignment entity before setting list view image flag"
    end
  end

  def to_label
    "#{description}"
  end
  
  def to_s
    "#{description}"
  end
  
  def before_destroy
    if da_assignment != nil && da_assignment.list_view_image_url == self.content_mgt_asset.digital_asset.url
      da_assignment.list_view_image_url = ''
      da_assignment.save
    end
  end
  
end
